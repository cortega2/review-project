class CreateJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :jobs do |t|
      t.text :status
      t.integer :review_id
      t.text :details
      t.text :url

      t.timestamps
    end
  end
end
