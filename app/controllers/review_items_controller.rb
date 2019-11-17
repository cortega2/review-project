class ReviewItemsController < ApplicationController
  before_action :set_review, only: [:show, :index]
  before_action :set_review_item, only: [:show]

  # GET /reviews/:review_id/review_items
  def index
    render json: { review_items: ReviewItem.where(review_id: @review.id) }
  end

  # GET /reviews/:review_id/review_items/:id
  def show
    render json: @review_item.to_json
  end

  private
    def set_review_item
      item_results = ReviewItem.where(id: params[:id], review_id: @review.id)
      if item_results.length == 0
        head :not_found
      end

      @review_item = item_results[0]
    end

    def set_review
      @review = Review.find_by_id(params[:review_id])
      if @review == nil
        head :not_found
      end
    end
end
