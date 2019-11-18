require 'lending_tree'
require 'date'

require 'pry'

describe CollectorJob, type: :job do
  context '#create_review_item' do
    it 'creates a new review item entry in the db' do
      data = {
        title: "title",
        text: "text",
        isRecommended: true,
        authorName: "name",
        userLocation: "Ohio",
        isAuthenticated: false,
        isVerifiedCustomer: false,
        isFlagged: false,
        primaryRating: {value: 1},
        submissionDateTime: DateTime.now,
        review_id: 1
      }

      job = CollectorJob.new
      job.create_review_item(data)

      expect(ReviewItem.count).to eq(1)
    end
  end

  context '#create_review_item' do
    it 'creates a new review item entry in the db' do
      data = {
        lender_name: "lender",
        lender_id: 1,
        lender_review_id: 2,
        reviewCount: 1,
        ratingOnlyCount: 1,
        averageOverallRating: 1,
        star_rating: 1
      }

      job = CollectorJob.new
      job.create_review(data)

      expect(Review.count).to eq(1)
    end
  end

  context '#update_job' do
    it 'updates the job entry and sends message to redis' do
      id = 1
      data = { id: id, status: 'new status'}

      allow(Job).to receive(:update).with(id, data).and_return(Job.new(data))
      allow($redis).to receive(:publish)

      job = CollectorJob.new
      job.update_job(id, data)

      expect($redis).to have_received(:publish).with("job.1", Job.new(data).to_json)
    end
  end

  context '#complete' do
    it 'updates job entry with done status and sends end message to redis' do
      id = 1
      data = { status: 'complete'}

      job = CollectorJob.new
      allow(job).to receive(:update_job).with(id, data)
      allow($redis).to receive(:publish)

      job.complete(id)
      expect($redis).to have_received(:publish).with("end.1", nil)
    end
  end

  context '#paginate' do
    it 'ends early if the client raises an error' do
      id = 1
      err = "Something bad happened"
      review = Review.new({id: 1, review_count: 100})

      client = double()
      allow(client).to receive(:review_items).and_raise(LendingTree::ClientError.new(err))

      job = CollectorJob.new
      allow(job).to receive(:update_job)
      allow($redis).to receive(:publish)

      job.paginate(id, client, review)
      expect(job).to have_received(:update_job).with(id, {status: "error", details: err})
      expect($redis).to have_received(:publish).with("end.1", nil)
    end

    it 'creates review items from the review item data' do
      id = 1
      review = Review.new({id: 1, review_count: 100})
      items = [
        {title: "worst restaurant ever!"}
      ]

      client = double()
      allow(client).to receive(:review_items).and_return(items)

      job = CollectorJob.new
      allow(job).to receive(:create_review_item).and_return(ReviewItem.new(items[0]))
      allow(job).to receive(:complete).with(id)
      allow($redis).to receive(:publish)

      job.paginate(id, client, review)
      expect(job).to have_received(:create_review_item).with(items[0].merge(review_id: review.id))
      expect($redis).to have_received(:publish).with("job.1", ReviewItem.new(items[0]).to_json)
    end
  end

  context '#collect_review' do
    let(:id) { 1 }
    let(:summary) {
      {
        reviewCount: 2189,
        averageOverallRating: 4.94,
        effectiveStarRating: 4.94
      }
    }
    let(:lender_info) {
      {
        lender_name: "name",
        lender_id: 1,
        lender_review_id: 2
      }
    }

    it 'stops processing if its a duplicate order' do
      err = "Already created"
      client = LendingTree::ReviewClient.new(lender_info[:lender_name], lender_info[:lender_id], lender_info[:lender_review_id])

      invalid_review = double()
      allow(invalid_review).to receive(:invalid?).and_return(true)
      allow(Review).to receive(:where).with(brand_id: client.lender_review_id).and_return([Review.new({id: 1,})])

      job = CollectorJob.new
      allow(job).to receive(:create_review).with(summary.merge(client.lender_info)).and_return(invalid_review)
      allow(job).to receive(:update_job)
      allow($redis).to receive(:publish)

      job.collect_review(id, client, summary)
      expect(job).to have_received(:update_job).with(id, {status: "rejected", review_id: 1, details: "Already created"})
      expect($redis).to have_received(:publish).with("end.1", nil)
    end

    it 'creates a new review and proceeds to get item pages' do
      client = LendingTree::ReviewClient.new(lender_info[:lender_name], lender_info[:lender_id], lender_info[:lender_review_id])

      valid_review = Review.new({id: 1})
      allow(valid_review).to receive(:invalid?).and_return(false)

      job = CollectorJob.new
      allow(job).to receive(:create_review).with(summary.merge(client.lender_info)).and_return(valid_review)
      allow(job).to receive(:update_job)
      allow(job).to receive(:paginate).with(id, client, valid_review)
      allow($redis).to receive(:publish)

      job.collect_review(id, client, summary)
      expect(job).to have_received(:update_job).with(id, {review_id: valid_review.id})
      expect($redis).to have_received(:publish).with("job.1", valid_review.to_json)
    end
  end

  context '#perform' do
    it 'updates the job entry status' do
      id = 1
      job_entry = Job.new({url: "test.com"})

      client = double()
      allow(client).to receive(:summary).and_return({})

      allow(LendingTree::ReviewClient).to receive(:from_url).and_return(client)
      allow(Job).to receive(:find).with(id).and_return(job_entry)

      job = CollectorJob.new
      allow(job).to receive(:update_job)
      allow(job).to receive(:collect_review)

      job.perform(id)
      expect(job).to have_received(:update_job).with(id, {status: "started"})
    end

    it 'terminates early when the client raises an error' do
      id = 1
      err = "Something bad happened"
      job_entry = Job.new({url: "test.com"})

      allow(LendingTree::ReviewClient).to receive(:from_url).and_raise(LendingTree::ClientError.new(err))
      allow(Job).to receive(:find).with(id).and_return(job_entry)

      job = CollectorJob.new
      allow(job).to receive(:update_job)
      allow($redis).to receive(:publish)

      job.perform(id)
      expect(job).to have_received(:update_job).with(id, {status: "started"}).ordered
      expect(job).to have_received(:update_job).with(id, {status: "error", details: err}).ordered
      expect($redis).to have_received(:publish).with("end.1", nil)
    end
  end
end
