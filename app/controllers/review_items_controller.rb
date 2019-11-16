class ReviewItemsController < ApplicationController
  before_action :set_review_item, only: [:show]

  # GET /review_items
  def index
    @review_items = ReviewItem.all
  end

  # GET /review_items/1
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review_item
      @review_item = ReviewItem.find(params[:id])
    end
end
