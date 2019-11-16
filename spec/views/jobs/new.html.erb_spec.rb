require 'rails_helper'

RSpec.describe "jobs/new", type: :view do
  before(:each) do
    assign(:job, Job.new(
      :status => "MyText",
      :review_id => 1,
      :details => "MyText",
      :url => "MyText"
    ))
  end

  it "renders new job form" do
    render

    assert_select "form[action=?][method=?]", jobs_path, "post" do

      assert_select "textarea[name=?]", "job[status]"

      assert_select "input[name=?]", "job[review_id]"

      assert_select "textarea[name=?]", "job[details]"

      assert_select "textarea[name=?]", "job[url]"
    end
  end
end
