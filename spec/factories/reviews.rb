FactoryBot.define do
  factory :review do
    lender_name { "MyString" }
    lender_id { 1 }
    brand_id { 1 }
    review_count { 1 }
    recommended_count { 1 }
    overall_rating { "9.99" }
    star_rating { "9.99" }
  end
end
