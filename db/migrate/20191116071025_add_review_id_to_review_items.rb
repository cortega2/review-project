class AddReviewIdToReviewItems < ActiveRecord::Migration[5.2]
  def change
    add_column :review_items, :review_id, :integer
  end
end
