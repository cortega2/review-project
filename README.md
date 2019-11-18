# Review Project
## Description
This application is meant to get reviews from a review website. The main endpoint streams data as its stored in the database, giving users instant feedback.

### Design
When working on this I wanted to acomplish the following goals.
1. Create an api to store review data.
2. Use async jobs using sucker punch to not hold up the main thread and be able to queue jobs.
3. Stream data back to the client.

The result of this is the application that behaves something like:
```
                        Database
                        |       \
                        |         \
                        |           \
request comes in        |             \
and we keep the   ----- Main Thread --> Async Job
connection open         |             /
                        |           /
                        |         /
                        |       /
                        Redis  PubSub  
```
## Requirements
ruby 2.6.3
sqlite
docker
docker-compose

## Install
* clone the repo
* bundle install
* bundle exec rake db:create
* bundle exec rake db:migrate

## Tests
This project uses rspec and the tests can be found in the spec folder.
To run the tests simply run `rspec`

## Running the Application
The application uses sqlite as its data store. It also uses Redis to pass messages between the background job and the main thread, therefore a redis instance needs to be up and running. The docker-compose file is prepared with redis.

* docker-compose up redis
* rails s

## Docker
Included is a docker-compose file that has the redis image.

## Endpoints
### GET /jobs
This is used to get all the jobs that have been executed.

#### Response
The GET endpoint returns a json structure of the jobs that are stored in the database.

##### JSON
`curl http://localhost:3000/jobs`
```
{
  "jobs": [
    {
      "id": 1,
      "status": "error",
      "review_id": null,
      "details": "failed to connect: getaddrinfo: nodename nor servname provided, or not known",
      "url": "https://dfgaravfasdfagregsfdasf.com/",
      "created_at": "2019-11-18T03:51:43.300Z",
      "updated_at": "2019-11-18T03:51:43.340Z"
    },
    {
      "id": 2,
      "status": "error",
      "review_id": null,
      "details": "Unable to find lender information",
      "url": "https://stackoverflow.com/",
      "created_at": "2019-11-18T03:51:59.243Z",
      "updated_at": "2019-11-18T03:51:59.502Z"
    },
    {
      "id": 3,
      "status": "complete",
      "review_id": 1,
      "details": null,
      "url": "https://www.lendingtree.com/reviews/mortgage/first-midwest-bank/49832469",
      "created_at": "2019-11-18T03:52:05.582Z",
      "updated_at": "2019-11-18T03:52:11.827Z"
    },
    {
      "id": 4,
      "status": "rejected",
      "review_id": 1,
      "details": "Already created",
      "url": "https://www.lendingtree.com/reviews/mortgage/first-midwest-bank/49832469",
      "created_at": "2019-11-18T03:52:57.255Z",
      "updated_at": "2019-11-18T03:52:57.529Z"
    }
  ]
}
```

### GET /jobs/id
This is used to get a single job that has been executed.

#### Response
The GET endpoint returns a json structure of the job that is stored in the database.

##### JSON
`curl http://localhost:3000/jobs/1`
```
{
    "id": 1,
    "status": "error",
    "review_id": null,
    "details": "failed to connect: getaddrinfo: nodename nor servname provided, or not known",
    "url": "https://dfgaravfasdfagregsfdasf.com/",
    "created_at": "2019-11-18T03:51:43.300Z",
    "updated_at": "2019-11-18T03:51:43.340Z"
}
```

### POST /jobs
The post jobs endpoint allows jobs to be queued. The job will then collect the review data. To post a job a url needs to be passed to the endpoint in the following format.
```
{
    "url": "https://www.lendingtree.com/reviews/mortgage/first-midwest-bank/49832469"
}
```
#### Response
The post jobs endpoint is a streaming endpoint and will stream all the available data and updates about the job while the connection is open.

##### Stream Examples

###### Providing a bad url
The application will attempt to get the page from the website, if it cant access the website it will update the job with that message and this info will be streamed to the user.
`curl --header "Content-Type: application/json" --request POST --data '{"url": "https://dfgaravfasdfagregsfdasf.com/"}' http://localhost:3000/jobs`
```
{"id":6,"status":"queued","review_id":null,"details":null,"url":"https://dfgaravfasdfagregsfdasf.com/","created_at":"2019-11-18T05:04:11.063Z","updated_at":"2019-11-18T05:04:11.063Z"}
{"id":6,"status":"started","review_id":null,"details":null,"url":"https://dfgaravfasdfagregsfdasf.com/","created_at":"2019-11-18T05:04:11.063Z","updated_at":"2019-11-18T05:04:11.070Z"}
{"id":6,"status":"error","details":"failed to connect: getaddrinfo: nodename nor servname provided, or not known","review_id":null,"url":"https://dfgaravfasdfagregsfdasf.com/","created_at":"2019-11-18T05:04:11.063Z","updated_at":"2019-11-18T05:04:11.097Z"}
```

###### Providing url that is not from the review website
If the application is able to access the page, it will then look for the lendor information. If it is not able to find that information, it will update the job with that message and this info will be streamed to the user.
`curl --header "Content-Type: application/json" --request POST --data '{"url": "https://stackoverflow.com/"}' http://localhost:3000/jobs`
```
{"id":7,"status":"queued","review_id":null,"details":null,"url":"https://stackoverflow.com/","created_at":"2019-11-18T05:07:14.173Z","updated_at":"2019-11-18T05:07:14.173Z"}
{"id":7,"status":"started","review_id":null,"details":null,"url":"https://stackoverflow.com/","created_at":"2019-11-18T05:07:14.173Z","updated_at":"2019-11-18T05:07:14.178Z"}
{"id":7,"status":"error","details":"Unable to find lender information","review_id":null,"url":"https://stackoverflow.com/","created_at":"2019-11-18T05:07:14.173Z","updated_at":"2019-11-18T05:07:14.461Z"}
```

###### Providing url for a review page that is already stored
The application stores all the reviews from the jobs. In the case that a job is created that is a duplicate of another previous job, the application will not proceed and display that information. Note that it will update the job to show the review id that corresponds with the url that was provided. This way the user can still get the reviews using the GET reviews end point.
`curl --header "Content-Type: application/json" --request POST --data '{"url": "https://www.lendingtree.com/reviews/mortgage/first-midwest-bank/49832469"}' http://localhost:3000/jobs`
```
{"id":5,"status":"queued","review_id":null,"details":null,"url":"https://www.lendingtree.com/reviews/mortgage/first-midwest-bank/49832469","created_at":"2019-11-18T05:03:05.359Z","updated_at":"2019-11-18T05:03:05.359Z"}
{"id":5,"status":"started","review_id":null,"details":null,"url":"https://www.lendingtree.com/reviews/mortgage/first-midwest-bank/49832469","created_at":"2019-11-18T05:03:05.359Z","updated_at":"2019-11-18T05:03:05.426Z"}
{"id":5,"status":"rejected","review_id":1,"details":"Already created","url":"https://www.lendingtree.com/reviews/mortgage/first-midwest-bank/49832469","created_at":"2019-11-18T05:03:05.359Z","updated_at":"2019-11-18T05:03:05.747Z"}
```

###### Providing a new review url
When a new review url is posted, the application will stream the updates of the job. This will include job update. Getting the summary of the page, and the individual review items.
`curl --header "Content-Type: application/json" --request POST --data '{"url": "https://www.lendingtree.com/reviews/mortgage/first-midwest-bank/49832469"}' http://localhost:3000/jobs`
```
{"id":1,"status":"queued","review_id":null,"details":null,"url":"https://www.lendingtree.com/reviews/mortgage/first-midwest-bank/49832469","created_at":"2019-11-18T05:19:37.225Z","updated_at":"2019-11-18T05:19:37.225Z"}                   {"id":1,"status":"started","review_id":null,"details":null,"url":"https://www.lendingtree.com/reviews/mortgage/first-midwest-bank/49832469","created_at":"2019-11-18T05:19:37.225Z","updated_at":"2019-11-18T05:19:37.235Z"}
{"id":1,"review_id":1,"status":"started","details":null,"url":"https://www.lendingtree.com/reviews/mortgage/first-midwest-bank/49832469","created_at":"2019-11-18T05:19:37.225Z","updated_at":"2019-11-18T05:19:37.527Z"}
{"id":1,"lender_name":"First Midwest Bank","lender_id":49832469,"brand_id":24100,"review_count":105,"recommended_count":0,"overall_rating":"4.89","star_rating":"3.27","created_at":"2019-11-18T05:19:37.522Z","updated_at":"2019-11-18T05:19:37.522Z"}                                                                            
{"id":1,"title":"Best loan experience","content":"Fast, honest and reliable. One of the best loan experiences of my life! They were easy to work with and immediately responded to all of my inquiries. ","recommended":true,"author_name":"Ryan","user_location":"EAGLE, CO ","authenticated":false,"verified_customer":false,"flagged":false,"primary_rating":5,"submission_datetime":"2019-09-16T11:02:07.512Z","created_at":"2019-11-18T05:19:37.676Z","updated_at":"2019-11-18T05:19:37.676Z","review_id":1}
.
.
.
{"id":104,"title":"awesome","content":"I have had great experience with Mandy and She answered all my questions with rapid response. Great customer service and helped me through out the Loan process with speed and accuracy. thank U again
Mandy!!","recommended":true,"author_name":"Patrick","user_location":"Concordia, MO","authenticated":true,"verified_customer":false,"flagged":false,"primary_rating":5,"submission_datetime":"2016-03-24T22:54:42.923Z","created_at":"2019-11-18T05:19:38.630Z","updated_at":"2019-11-18T05:19:38.630Z","review_id":1}
{"id":1,"status":"complete","review_id":1,"details":null,"url":"https://www.lendingtree.com/reviews/mortgage/first-midwest-bank/49832469","created_at":"2019-11-18T05:19:37.225Z","updated_at":"2019-11-18T05:19:38.637Z"}
```

### GET /reviews
This is used to get all the review summaries for all reviews that have been collected.

#### Response
The GET endpoint returns a json structure of the review summaries.

##### JSON
`curl http://localhost:3000/reviews`
```
{
  "reviews": [
    {
      "id": 1,
      "lender_name": "First Midwest Bank",
      "lender_id": 49832469,
      "brand_id": 24100,
      "review_count": 105,
      "recommended_count": 0,
      "overall_rating": "4.89",
      "star_rating": "3.27",
      "created_at": "2019-11-18T05:19:37.522Z",
      "updated_at": "2019-11-18T05:19:37.522Z"
    }
  ]
}
```

### GET /reviews/id
This is used to get a single review summary.

#### Response
The GET endpoint returns a json structure of the review summary.

##### JSON
`curl http://localhost:3000/reviews/1`
```
{
  "id": 1,
  "lender_name": "First Midwest Bank",
  "lender_id": 49832469,
  "brand_id": 24100,
  "review_count": 105,
  "recommended_count": 0,
  "overall_rating": "4.89",
  "star_rating": "3.27",
  "created_at": "2019-11-18T05:19:37.522Z",
  "updated_at": "2019-11-18T05:19:37.522Z"
}
```

### GET /reviews/id/review_items
This is used to get all the review items from a lender review.

#### Response
The GET endpoint returns a json structure of the review items.

##### JSON
`curl http://localhost:3000/reviews/1/review_items`
```
{
  "review_items": [
    {
      "id": 1,
      "title": "Best loan experience",
      "content": "Fast, honest and reliable. One of the best loan experiences of my life! They were easy to work with and immediately responded to all of my inquiries. ",
      "recommended": true,
      "author_name": "Ryan",
      "user_location": "EAGLE, CO ",
      "authenticated": false,
      "verified_customer": false,
      "flagged": false,
      "primary_rating": 5,
      "submission_datetime": "2019-09-16T11:02:07.512Z",
      "created_at": "2019-11-18T05:19:37.676Z",
      "updated_at": "2019-11-18T05:19:37.676Z",
      "review_id": 1
    },
    ...
  ]
}
```

### GET /reviews/id/review_items/id
This is used to get a single review item from a lender review.

#### Response
The GET endpoint returns a json structure of the review item.

##### JSON
`curl http://localhost:3000/reviews/1/review_items/1`
```
{
  "id": 1,
  "title": "Best loan experience",
  "content": "Fast, honest and reliable. One of the best loan experiences of my life! They were easy to work with and immediately responded to all of my inquiries. ",
  "recommended": true,
  "author_name": "Ryan",
  "user_location": "EAGLE, CO ",
  "authenticated": false,
  "verified_customer": false,
  "flagged": false,
  "primary_rating": 5,
  "submission_datetime": "2019-09-16T11:02:07.512Z",
  "created_at": "2019-11-18T05:19:37.676Z",
  "updated_at": "2019-11-18T05:19:37.676Z",
  "review_id": 1
}
```

## TODO
Unfortunately I didn't get the chance to do everything that I wanted to do with this project. These are some of the things that I think would improve it.
### Source Code Based
* /app/models/review_item.rb:  # TODO: Add that it belongs to a review
* ./app/models/review.rb:  # TODO: Add that it has many reviews
* ./app/models/review.rb:  # TODO Add that lender id and review id need to be unique
* ./app/jobs/collector_job.rb:    # TODO verify that the number of review items that we are getting matches the total number of reviews
* ./app/controllers/application_controller.rb:  # TODO remove the active storage stuff
* /lib/lending_tree.rb:    # TODO: Consider adding some error checking when parsing the data
* ./lib/lending_tree.rb:    #TODO: Investigate what options are requred to return review

### General
* Create a docker file for the application
* Create production configuration and use mysql instead of sqlite
* Better testing of the multithreading functionality to see how well it scales up with concurrent connections

## Last Remarks
I really enjoyed working on this. It was fun trying to come up with a way to get rid of the latency by using a stream instead of a traditional api method. It was also interesting trying to incorporate background jobs with the main thread. Since we wanted to have a constant feed of data. 
