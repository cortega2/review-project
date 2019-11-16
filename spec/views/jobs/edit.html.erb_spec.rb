require 'rails_helper'

RSpec.describe "jobs/edit", type: :view do
  before(:each) do
    @job = assign(:job, Job.create!(
      :status => "MyText",
      :review_id => 1,
      :details => "MyText",
      :url => "MyText"
    ))
  end

  it "renders the edit job form" do
    render

    assert_select "form[action=?][method=?]", job_path(@job), "post" do

      assert_select "textarea[name=?]", "job[status]"

      assert_select "input[name=?]", "job[review_id]"

      assert_select "textarea[name=?]", "job[details]"

      assert_select "textarea[name=?]", "job[url]"
    end
  end
end
