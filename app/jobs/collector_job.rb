require 'http'
require 'json'

class CollectorJob
  include SuckerPunch::Job

  def perform(id)
    url = Job.find(id).url
    update_job(id, {status: "started"})

    lender_info = lender_information(url)
    if lender_info[:error]
      update_job(id, {status: "error", details: lender_info[:error]})
      $redis.publish("end.#{id}", nil)
      return
    end

    summary = review_summary(lender_info[:lender_review_id])
    if summary[:error]
      update_job(id, {status: "error", details: summary[:error]})
      $redis.publish("end.#{id}", nil)
      return
    end

    review = create_review(summary.merge(lender_info))
    if review.invalid?
      old_review = Review.where(brand_id: lender_info[:lender_review_id])[0]
      update_job(id, {status: "rejected", review_id: old_review.id, details: "Already created"})
      $redis.publish("end.#{id}", nil)
      return
    end

    update_job(id, {review_id: review.id})
    $redis.publish("job.#{id}", review.to_json)

    page_size = 100
    total_pages = (summary[:reviewCount].to_f / page_size.to_f).ceil(0)

    # TODO verify that the number of review items that we are getting matches the total number of reviews
    # I have reason to suspect that their api is doing something with their pagination that may cause us to
    # have duplicate reviews or perhaps missing reviews
    total_pages.times do | p |
      items = review_items(lender_info[:lender_review_id], p, page_size)
      if items[:error]
        update_job(id, {status: "error", details: items[:error]})
        $redis.publish("end.#{id}", nil)
        return
      end

      items[:reviews].each do | item |
        create_review_item(item.merge({review_id: review.id, job_id: id}))
      end
    end

    # we are done with this job
    update_job(id, {status: "complete"})
    $redis.publish("end.#{id}", nil)
  end

  # TODO: Consider moving these methods into a libray module for lending website
  def lender_information(url)
    result = request(url)
    if result[:error]
      return result
    end

    matches = /data-lendername="(.*)" data-lenderid="(\d*)" data-lenderreviewid="(\d*)"/.match(result[:data])
    if matches == nil || matches.length < 4
      return {error: "Unable to find lender information"}
    end

    return {lender_name: matches[1], lender_id: matches[2], lender_review_id: matches[3]}
  end

  def review_summary(lender_review_id)
    # get first page to get the summary info
    page = request(api_url(lender_review_id, 0, 1))
    if page[:error]
      return result
    end

    data = JSON.parse(page[:data], {symbolize_names: true})
    return data[:result][:statistics]
  end

  def review_items(lender_review_id, page_number, page_size)
    page = request(api_url(lender_review_id, page_number, page_size))
    if page[:error]
      return page
    end

    data = JSON.parse(page[:data], {symbolize_names: true})
    return {reviews: data[:result][:reviews]}
  end

  def request(url)
    begin
      resp = HTTP.get(url)
      error = resp.code <= 299 ? nil : "Non 200 status"
      return { data: resp.body.to_s, error: error }
    rescue HTTP::Error => e
      return {data: nil, error: e.to_s}
    end
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

      review = ReviewItem.create(params)
      $redis.publish("job.#{item[:job_id]}", review.to_json)
    end
  end

  def api_url(review_id, page, size)
    "https://www.lendingtree.com/content/mu-plugins/lt-review-api/review-api-proxy.php?RequestType=&productType=&brandId=#{review_id}&requestmode=reviews,stats,ratingconfig,propertyconfig&page=#{page}&sortby=reviewsubmitted&sortorder=desc&pagesize=#{size}&AuthorLocation=All"
  end
end
