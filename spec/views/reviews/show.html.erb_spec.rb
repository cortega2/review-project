require 'rails_helper'

RSpec.describe "reviews/show", type: :view do
  before(:each) do
    @review = assign(:review, Review.create!(
      :lenderName => "Lender Name",
      :lenderId => 2,
      :brandId => 3,
      :reviewCount => 4,
      :recommendedCount => 5,
      :averageOverallRating => "9.99",
      :effectiveStarRating => "9.99"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Lender Name/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/9.99/)
  end
end
