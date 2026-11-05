class PollsController < ApplicationController

  include LoadAndAuthorize
  include EmailHelper

  helper :email

  def show
    @poll = ModelLocator.new(:poll, params).locate!
    return respond_with_error(403) unless current_user.can?(:show, @poll)

    respond_to do |format|
      format.html do
        data = initial_page_data(topicable: @poll) unless params[:export] || browser.bot?
        boot_app(initial_data: data)
      end
    end
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
