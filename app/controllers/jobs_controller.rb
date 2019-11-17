class JobsController < ApplicationController
  include ActionController::Live
  before_action :set_job, only: [:show]

  # GET /jobs
  def index
    render json: { jobs: Job.all }
  end

  # GET /jobs/1
  def show
    render json: @job.to_json
  end

  # POST /jobs
  def create
    redis = Redis.new

    puts "this is the url"
    puts params[:url]

    job = Job.create({url: params[:url], status: "queued"})
    response.stream.write(job.to_json + "\n")

    begin
      CollectorJob.perform_async(job.id)
    rescue Concurrent::RejectedExecutionError => e
      render json: {error: "Unable to create job"}, status: :too_many_requests and return
    end

    redis.subscribe("job.#{job.id}", "end.#{job.id}") do | on |
      on.message do |event, data|
        response.stream.write(data + "\n")
        redis.unsubscribe if event == "end.#{job.id}"
      end
    end
  rescue IOError
    logger.info "Stream has closed"
  ensure
    redis.quit
    response.stream.close
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_job
      @job = Job.find_by_id(params[:id])
      if @job == nil
        head :not_found
      end
    end

    # Only allow a trusted parameter "white list" through.
    def job_params
      params.require(:url)
    end
end
