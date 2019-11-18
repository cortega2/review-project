require 'rails_helper'

RSpec.describe ReviewsController, type: :controller do
  describe "GET #index" do
    it "returns a success response" do
      review = FactoryBot.create(:review)
      get :index, params: {}
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      review = FactoryBot.create(:review)
      get :show, params: {id: review.to_param}
      expect(response).to be_successful
    end
  end
end
