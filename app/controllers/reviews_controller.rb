class ReviewsController < ApplicationController
  before_action :set_review, only: [:show]

  # GET /reviews
  def index
    @reviews = Review.all
  end

  # GET /reviews/1
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review
      @review = Review.find(params[:id])
    end
end
