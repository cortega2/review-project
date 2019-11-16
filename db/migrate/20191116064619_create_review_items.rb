class CreateReviewItems < ActiveRecord::Migration[5.2]
  def change
    create_table :review_items do |t|
      t.text :title
      t.text :content
      t.boolean :recommended
      t.text :author_name
      t.text :user_location
      t.boolean :authenticated
      t.boolean :verified_customer
      t.boolean :flagged
      t.integer :primary_rating
      t.datetime :submission_datetime

      t.timestamps
    end
  end
end
