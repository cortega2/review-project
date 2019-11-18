require 'rails_helper'
require 'pry'

RSpec.describe JobsController, type: :controller do
  describe "GET #index" do
    it "returns a success response" do
      job = FactoryBot.create(:job)
      get :index, params: {}
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      job = FactoryBot.create(:job)
      get :show, params: {id: job.id}
      expect(response).to be_successful
    end
  end

  # NOTE
  # I was following this guide to test the redis part of the code
  # https://gist.github.com/juanhiplogiq/8100263, however it's not clear if checking agains the
  # response body is the best way to do this since what is in that guide doesnt work here
  describe "POST #create" do
    context "when the queue is full" do
      it "returns a too many request error" do
        redis = double()
        allow(redis).to receive(:quit)

        job = Job.new({url: "test.com"})

        allow(Redis).to receive(:new).and_return(redis)
        allow(Job).to receive(:create).and_return(job)
        allow(CollectorJob).to receive(:perform_async).and_raise(Concurrent::RejectedExecutionError.new)

        post :create, params: {url: "test.com"}
        expect(response.body).to eq(job.to_json + "\n" + {error: "Unable to create job due to queue being full"}.to_json + "\n")
      end
    end

    context "when a job is accepted" do
      it "streams job data" do
        data = {field: "value"}
        job = Job.new({id: 1, url: "test.com"})

        r_message = double()
        allow(r_message).to receive(:message).and_yield("job.#{job.id}", data.to_json)

        redis = double()
        allow(redis).to receive(:subscribe).with("job.#{job.id}", "end.#{job.id}").and_yield(r_message)
        allow(redis).to receive(:quit)

        allow(Redis).to receive(:new).and_return(redis)
        allow(Job).to receive(:create).and_return(job)
        allow(CollectorJob).to receive(:perform_async)

        post :create, params: {url: "test.com"}
        expect(response.body).to eq(job.to_json + "\n" + data.to_json + "\n")
      end
    end
  end
end
