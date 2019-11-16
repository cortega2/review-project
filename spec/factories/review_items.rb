FactoryBot.define do
  factory :review_item do
    title { "MyText" }
    content { "MyText" }
    recommended { false }
    author_name { "MyText" }
    user_location { "MyText" }
    authenticated { false }
    verified_customer { false }
    flagged { false }
    primary_rating { 1 }
    submission_datetime { "2019-11-16 00:46:19" }
  end
end
