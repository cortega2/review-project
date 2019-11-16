require 'rails_helper'

RSpec.describe "reviews/new", type: :view do
  before(:each) do
    assign(:review, Review.new(
      :lenderName => "MyString",
      :lenderId => 1,
      :brandId => 1,
      :reviewCount => 1,
      :recommendedCount => 1,
      :averageOverallRating => "9.99",
      :effectiveStarRating => "9.99"
    ))
  end

  it "renders new review form" do
    render

    assert_select "form[action=?][method=?]", reviews_path, "post" do

      assert_select "input[name=?]", "review[lenderName]"

      assert_select "input[name=?]", "review[lenderId]"

      assert_select "input[name=?]", "review[brandId]"

      assert_select "input[name=?]", "review[reviewCount]"

      assert_select "input[name=?]", "review[recommendedCount]"

      assert_select "input[name=?]", "review[averageOverallRating]"

      assert_select "input[name=?]", "review[effectiveStarRating]"
    end
  end
end
