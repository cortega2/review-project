require "rails_helper"

RSpec.describe ReviewItemsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "reviews/1/review_items").to route_to("review_items#index", :review_id => "1")
    end

    it "routes to #show" do
      expect(:get => "reviews/1/review_items/1").to route_to("review_items#show", :review_id => "1", :id => "1")
    end
  end
end
