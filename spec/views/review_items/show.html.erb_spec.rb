require 'rails_helper'

RSpec.describe "review_items/show", type: :view do
  before(:each) do
    @review_item = assign(:review_item, ReviewItem.create!(
      :title => "MyText",
      :content => "MyText",
      :recommended => false,
      :authorName => "MyText",
      :userLocation => "MyText",
      :authenticated => false,
      :verifiedCustomer => false,
      :flagged => false,
      :primaryRating => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/2/)
  end
end
