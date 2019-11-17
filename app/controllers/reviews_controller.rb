class ReviewsController < ApplicationController
  before_action :set_review, only: [:show]

  # GET /reviews
  def index
    render json: { reviews: Review.all }
  end

  # GET /reviews/1
  def show
    render json: @review.to_json
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review
      @review = Review.find_by_id(params[:id])
      if @review == nil
        head :not_found
      end
    end
end
