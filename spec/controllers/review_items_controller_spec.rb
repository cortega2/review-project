require 'rails_helper'

RSpec.describe ReviewItemsController, type: :controller do
  describe "GET #index" do
    it "returns a success response" do
      review = FactoryBot.create(:review)
      review_item = FactoryBot.create(:review_item, review_id: review.id)
      get :index, params: {review_id: review.id}
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      review = FactoryBot.create(:review)
      review_item = FactoryBot.create(:review_item, review_id: review.id)
      get :show, params: {review_id: review.id, id: review_item.id}
      expect(response).to be_successful
    end
  end
end
