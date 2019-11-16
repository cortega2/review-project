require 'rails_helper'

RSpec.describe "reviews/edit", type: :view do
  before(:each) do
    @review = assign(:review, Review.create!(
      :lenderName => "MyString",
      :lenderId => 1,
      :brandId => 1,
      :reviewCount => 1,
      :recommendedCount => 1,
      :averageOverallRating => "9.99",
      :effectiveStarRating => "9.99"
    ))
  end

  it "renders the edit review form" do
    render

    assert_select "form[action=?][method=?]", review_path(@review), "post" do

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
