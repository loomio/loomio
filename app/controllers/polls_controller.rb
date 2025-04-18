class PollsController < ApplicationController

  include LoadAndAuthorize
  include EmailHelper

  helper :email

  def export
    @exporter = PollExporter.new(load_and_authorize(:poll, :export))
    @recipient = current_user
    @action_name = :export

    respond_to do |format|
      format.html
      format.csv { send_data @exporter.to_csv, filename:@exporter.file_name }
    end
  end

  def example
    if poll = PollGenerator.new(params[:type]).generate!
      redirect_to poll
    else
      redirect_to root_path, notice: "Sorry, we don't know about that poll type"
    end
  end

  private

  def current_user
    restricted_user || super
  end
end
