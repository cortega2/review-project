# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_11_16_071025) do

  create_table "jobs", force: :cascade do |t|
    t.text "status"
    t.integer "review_id"
    t.text "details"
    t.text "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "review_items", force: :cascade do |t|
    t.text "title"
    t.text "content"
    t.boolean "recommended"
    t.text "author_name"
    t.text "user_location"
    t.boolean "authenticated"
    t.boolean "verified_customer"
    t.boolean "flagged"
    t.integer "primary_rating"
    t.datetime "submission_datetime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "review_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.string "lender_name"
    t.integer "lender_id"
    t.integer "brand_id"
    t.integer "review_count"
    t.integer "recommended_count"
    t.decimal "overall_rating"
    t.decimal "star_rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
