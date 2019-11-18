require 'http'
require 'json'

module LendingTree
  class ReviewClient
    attr_reader :lender_name, :lender_id, :lender_review_id
    def initialize(lender_name, lender_id, lender_review_id)
      @lender_name = lender_name
      @lender_id = lender_id
      @lender_review_id = lender_review_id
    end

    def lender_info
      {
        lender_name: @lender_name,
        lender_id: @lender_id,
        lender_review_id: @lender_review_id
      }
    end

    # TODO: Consider adding some error checking when parsing the data
    # we are not doing error checking on the data we get back from the api
    # cause im under the assumtiption that their api will not return an unparasable file
    def summary
      # get first page to get the summary info
      page = ReviewClient.request(ReviewClient.api_url(@lender_review_id, 0, 1))
      data = JSON.parse(page, {symbolize_names: true})
      return data[:result][:statistics]
    end

    # Ideally we would want some kind of paginator object to iterate over the
    # api pages but this will have to do for now
    def review_items(page_number, page_size)
      page = ReviewClient.request(ReviewClient.api_url(@lender_review_id, page_number, page_size))
      data = JSON.parse(page, {symbolize_names: true})
      return data[:result][:reviews]
    end

    def self.from_url(url)
      result = ReviewClient.request(url)

      matches = /data-lendername="(.*)" data-lenderid="(\d*)" data-lenderreviewid="(\d*)"/.match(result)
      if matches == nil || matches.length < 4
        raise LendingTree::ClientError.new("Unable to find lender information")
      end

      return ReviewClient.new(matches[1], matches[2], matches[3])
    end

    def self.request(url)
      begin
        resp = HTTP.get(url)
        error = resp.code <= 299 ? nil : "Non 200 status"
        if resp.code >= 300
          raise LendingTree::ClientError.new("Url request returned non 200 status")
        else
          return resp.body.to_s
        end
      rescue HTTP::Error => e
        raise LendingTree::ClientError.new(e.to_s)
      end
    end

    #TODO: Investigate what options are requred to return review
    # all the current options might not be needed
    def self.api_url(review_id, page, size)
      "https://www.lendingtree.com/content/mu-plugins/lt-review-api/review-api-proxy.php?"\
      "RequestType=&productType="\
      "&brandId=#{review_id}"\
      "&requestmode=reviews,stats,ratingconfig,propertyconfig"\
      "&page=#{page}"\
      "&sortby=reviewsubmitted&sortorder=desc"\
      "&pagesize=#{size}"\
      "&AuthorLocation=All"
    end
  end

  class ClientError < StandardError
    def initialize(message)
      super message
    end
  end
end
