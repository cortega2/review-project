require './lib/lending_tree'

class CollectorJob
  include SuckerPunch::Job

  def perform(id)
    url = Job.find(id).url
    update_job(id, {status: "started"})

    # get summary
    begin
      client = LendingTree::ReviewClient.from_url(url)
      summary = client.summary
    rescue LendingTree::ClientError => e
      update_job(id, {status: "error", details: e.to_s})
      $redis.publish("end.#{id}", nil)
      return
    end

    collect_review(id, client, summary)
  end

  def collect_review(job_id, client, summary)
    # create review entry
    review = create_review(summary.merge(client.lender_info))
    if review.invalid?
      old_review = Review.where(brand_id: client.lender_review_id)[0]
      update_job(job_id, {status: "rejected", review_id: old_review.id, details: "Already created"})
      $redis.publish("end.#{job_id}", nil)
      return
    end

    update_job(job_id, {review_id: review.id})
    $redis.publish("job.#{job_id}", review.to_json)

    paginate(job_id, client, review)
  end

  def paginate(job_id, client, review)
    # set page size
    page_size = 100
    total_pages = (review.review_count.to_f / page_size.to_f).ceil(0)

    # TODO verify that the number of review items that we are getting matches the total number of reviews
    # I have reason to suspect that their api is doing something with their pagination that may cause us to
    # have duplicate reviews or perhaps missing reviews
    total_pages.times do | p |
      begin
        items = client.review_items(p, page_size)
      rescue LendingTree::ClientError => e
        update_job(job_id, {status: "error", details: e.to_s})
        $redis.publish("end.#{job_id}", nil)
        return
      end

      items.each do | item |
        review_item = create_review_item(item.merge({review_id: review.id}))
        $redis.publish("job.#{job_id}", review_item.to_json)
      end
    end

    complete(job_id)
  end

  def complete(job_id)
    # we are done with this job
    update_job(job_id, {status: "complete"})
    $redis.publish("end.#{job_id}", nil)
  end

  def update_job(id, data)
    ActiveRecord::Base.connection_pool.with_connection do
      job = Job.update(id, data)
      $redis.publish("job.#{id}", job.to_json)
    end
  end

  def create_review(data)
    ActiveRecord::Base.connection_pool.with_connection do
      params = {
        lender_name: data[:lender_name],
        lender_id: data[:lender_id],
        brand_id: data[:lender_review_id],
        review_count: data[:reviewCount],
        recommended_count: data[:ratingOnlyCount],
        overall_rating: data[:averageOverallRating],
        star_rating: data[:effectiveStarRating]
      }

      return Review.create(params)
    end
  end

  def create_review_item(item)
    ActiveRecord::Base.connection_pool.with_connection do
      params = {
        title: item[:title],
        content: item[:text],
        recommended: item[:isRecommended],
        author_name: item[:authorName],
        user_location: item[:userLocation],
        authenticated: item[:isAuthenticated],
        verified_customer: item[:isVerifiedCustomer],
        flagged: item[:isFlagged],
        primary_rating: item[:primaryRating][:value],
        submission_datetime: item[:submissionDateTime],
        review_id: item[:review_id]
      }

      return ReviewItem.create(params)
    end
  end
end
