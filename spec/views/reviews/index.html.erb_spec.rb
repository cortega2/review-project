require 'rails_helper'

RSpec.describe "reviews/index", type: :view do
  before(:each) do
    assign(:reviews, [
      Review.create!(
        :lenderName => "Lender Name",
        :lenderId => 2,
        :brandId => 3,
        :reviewCount => 4,
        :recommendedCount => 5,
        :averageOverallRating => "9.99",
        :effectiveStarRating => "9.99"
      ),
      Review.create!(
        :lenderName => "Lender Name",
        :lenderId => 2,
        :brandId => 3,
        :reviewCount => 4,
        :recommendedCount => 5,
        :averageOverallRating => "9.99",
        :effectiveStarRating => "9.99"
      )
    ])
  end

  it "renders a list of reviews" do
    render
    assert_select "tr>td", :text => "Lender Name".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
  end
end
