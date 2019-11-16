require 'rails_helper'

RSpec.describe "review_items/edit", type: :view do
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
      :primaryRating => 1
    ))
  end

  it "renders the edit review_item form" do
    render

    assert_select "form[action=?][method=?]", review_item_path(@review_item), "post" do

      assert_select "textarea[name=?]", "review_item[title]"

      assert_select "textarea[name=?]", "review_item[content]"

      assert_select "input[name=?]", "review_item[recommended]"

      assert_select "textarea[name=?]", "review_item[authorName]"

      assert_select "textarea[name=?]", "review_item[userLocation]"

      assert_select "input[name=?]", "review_item[authenticated]"

      assert_select "input[name=?]", "review_item[verifiedCustomer]"

      assert_select "input[name=?]", "review_item[flagged]"

      assert_select "input[name=?]", "review_item[primaryRating]"
    end
  end
end
