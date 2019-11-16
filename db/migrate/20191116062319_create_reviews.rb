class CreateReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :reviews do |t|
      t.string :lender_name
      t.integer :lender_id
      t.integer :brand_id
      t.integer :review_count
      t.integer :recommended_count
      t.decimal :overall_rating
      t.decimal :star_rating

      t.timestamps
    end
  end
end
