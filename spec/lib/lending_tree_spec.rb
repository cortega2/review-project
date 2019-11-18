require 'lending_tree'
require 'http'

RSpec.describe LendingTree::ClientError do
  context '::new' do
    it 'creates a new error with a message' do
      err = LendingTree::ClientError.new("Error message")
      expect(err.to_s).to eq("Error message")
    end
  end
end

RSpec.describe LendingTree::ReviewClient do
  let(:url) { "http://test.com" }
  let(:info) {
    {
      lender_name: "name",
      lender_id: 1,
      lender_review_id: 2
    }
  }

  context '::api_url' do
    it 'creates a valid url given an id, page, and page size' do
      id = 1
      page = 2
      size = 3

      expected_url =
        "https://www.lendingtree.com/content/mu-plugins/lt-review-api/review-api-proxy.php?"\
        "RequestType=&productType="\
        "&brandId=#{id}"\
        "&requestmode=reviews,stats,ratingconfig,propertyconfig"\
        "&page=#{page}"\
        "&sortby=reviewsubmitted&sortorder=desc"\
        "&pagesize=#{size}"\
        "&AuthorLocation=All"

      expect(LendingTree::ReviewClient.api_url(id, page, size)).to eq(expected_url)
    end
  end

  context '::request' do
    it 'raises error if status is not 200' do
      stub_request(:get, url).to_return(status: 400)
      expect {LendingTree::ReviewClient.request(url) }.to raise_error(LendingTree::ClientError, "Url request returned non 200 status")
    end

    it 'raises error if http libray raises an error' do
      stub_request(:get, url).to_raise(HTTP::Error.new())
      expect {LendingTree::ReviewClient.request(url) }.to raise_error(LendingTree::ClientError)
    end

    it 'returns a string representation of the body' do
      response = {
        field: "value"
      }.to_json

      stub_request(:get, url).to_return({body: response}, status: 200)
      expect(LendingTree::ReviewClient.request(url)).to eq(response.to_s)
    end
  end

  context '::from_url' do
    it 'raises error if lender info is not in the page data' do
      page_data = "<!DOCTYPE html><html><head></head> <body></body></html>"
      allow(LendingTree::ReviewClient).to receive(:request).and_return(page_data)
      expect {LendingTree::ReviewClient.from_url("") }.to raise_error(LendingTree::ClientError, "Unable to find lender information")
    end

    it 'creates a new client object with the lender info from the url' do
      page_data = '<a class="reviewBtn write-review" data-lendername="NBKC Bank" data-lenderid="291269" data-lenderreviewid="191785" data-vertical="mortgage">Write a Review</a>'
      allow(LendingTree::ReviewClient).to receive(:request).and_return(page_data)
      allow(LendingTree::ReviewClient).to receive(:new).and_return(double())

      LendingTree::ReviewClient.from_url("")
      expect(LendingTree::ReviewClient).to have_received(:new).with("NBKC Bank", "291269", "191785")
    end
  end

  context '::new' do
    it 'creates a new client object' do
      client = LendingTree::ReviewClient.new(info[:lender_name], info[:lender_id], info[:lender_review_id])
      expect(client.lender_name).to eq(info[:lender_name])
      expect(client.lender_id).to eq(info[:lender_id])
      expect(client.lender_review_id).to eq(info[:lender_review_id])
    end
  end

  context '#lender_info' do
    it 'creates a new client object' do
      client = LendingTree::ReviewClient.new(info[:lender_name], info[:lender_id], info[:lender_review_id])
      expect(client.lender_info).to eq(info)
    end
  end

  context '#summary' do
    it 'returns the summary information for the review' do
      data = {
  		  total: 2189,
  		  filteredCount: 2190,
  		  result: {
       		statistics: {
        	  reviewCount: 2189,
        	  ratingOnlyCount: 0,
        	  recommendedCount: 2163,
        	  averageOverallRating: 4.94,
        	  effectiveStarRating: 4.94,
   	  		  insertTimestamp: "2018-03-20T20:44:22.041+00:00",
            updateTimestamp: "2019-11-13T15:16:31.474+00:00",
            average30Days: 324,
            reviewsOf: "all",
            totalReviewCount: 0,
            last90daysreviewcount: 0,
            isCertified: false,
            productId: "27085",
            productType: "lender",
            brandId: "27085",
            lenderId: 0
          }
        }
      }

      allow(LendingTree::ReviewClient).to receive(:api_url).with(info[:lender_review_id], 0, 1).and_return(url)
      allow(LendingTree::ReviewClient).to receive(:request).with(url).and_return(data.to_json.to_s)

      client = LendingTree::ReviewClient.new(info[:lender_name], info[:lender_id], info[:lender_review_id])
      expect(client.summary).to eq(data[:result][:statistics])
    end
  end

  context '#review_items' do
    it 'returns the summary information for the review' do
      page = 1
      size = 2

      data = {
  		  result: {
       		reviews: [
            {
              id: "5dcc3a62ff72b000013cb891",
              productId: "27085",
              title: "Quick and Easy"
            }
          ]
        }
      }

      allow(LendingTree::ReviewClient).to receive(:api_url).with(info[:lender_review_id], page, size).and_return(url)
      allow(LendingTree::ReviewClient).to receive(:request).with(url).and_return(data.to_json.to_s)

      client = LendingTree::ReviewClient.new(info[:lender_name], info[:lender_id], info[:lender_review_id])
      expect(client.review_items(page, size)).to eq(data[:result][:reviews])
    end
  end
end
