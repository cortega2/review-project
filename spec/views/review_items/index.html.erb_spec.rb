require 'rails_helper'

RSpec.describe "review_items/index", type: :view do
  before(:each) do
    assign(:review_items, [
      ReviewItem.create!(
        :title => "MyText",
        :content => "MyText",
        :recommended => false,
        :authorName => "MyText",
        :userLocation => "MyText",
        :authenticated => false,
        :verifiedCustomer => false,
        :flagged => false,
        :primaryRating => 2
      ),
      ReviewItem.create!(
        :title => "MyText",
        :content => "MyText",
        :recommended => false,
        :authorName => "MyText",
        :userLocation => "MyText",
        :authenticated => false,
        :verifiedCustomer => false,
        :flagged => false,
        :primaryRating => 2
      )
    ])
  end

  it "renders a list of review_items" do
    render
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
