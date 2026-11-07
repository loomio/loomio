class PollsController < ApplicationController

  include LoadAndAuthorize
  include EmailHelper

  helper :email

  def show
    resource = ModelLocator.new(resource_name, params).locate!
    @recipient = current_user
    return respond_with_error 403 unless current_user.can?(:show, resource)

    assign_resource
    return boot_app(resource: @poll) unless params[:export] || browser.bot?

    # The poll page shows the poll's topic. A poll in a thread shares the thread's
    # topic, so its canonical URL is the thread's, to avoid indexing it twice.
    topicable = @poll.topic.topicable
    render_topic(@poll.topic, canonical: topicable.is_a?(Discussion) ? topicable : @poll)
  end

  def export
    @poll = load_and_authorize(:poll, :export)
    @exporter = PollExporter.new(@poll)
    @recipient = current_user
    @action_name = :export

    respond_to do |format|
      format.html do
        render Views::Polls::Export.new(
          poll: @poll, exporter: @exporter, recipient: @recipient
        )
      end
      format.csv { send_data @exporter.to_csv, filename: @exporter.file_name }
      format.blt { send_data @exporter.to_blt, filename: @exporter.blt_file_name }
    end
  end

  def example
    if poll = PollGenerator.new(params[:type]).generate!
      redirect_to poll
    else
      redirect_to root_path, notice: "Sorry, we don't know about that poll type"
    end
  end

end
