class JobsController < ApplicationController
  include ActionController::Live
  before_action :set_job, only: [:show]

  # GET /jobs
  def index
    @jobs = Job.all
  end

  # GET /jobs/1
  def show
  end

  # POST /jobs
  def create
    puts "this is the url"
    puts params[:url]

    puts params
    3.times do | n |
      response.stream.write("#{n}...\n\n")
      sleep 2
    end
  ensure
    response.stream.close
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_job
      @job = Job.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def job_params
      params.require(:url)
    end
end
