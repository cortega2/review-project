require 'rails_helper'

RSpec.describe "ReviewItems", type: :request do
  describe "GET /review_items" do
    it "works! (now write some real specs)" do
      get review_items_path
      expect(response).to have_http_status(200)
    end
  end
end
