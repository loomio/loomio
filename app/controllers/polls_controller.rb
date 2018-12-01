class PollsController < ApplicationController

  include UsesMetadata
  include LoadAndAuthorize
  include EmailHelper

  helper :email

  def export
    @exporter = PollExporter.new(load_and_authorize(:poll, :export))
    @info = @exporter.poll_info(current_user)

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

  def unsubscribe
    PollService.toggle_subscription(poll: resource, actor: current_user) if is_subscribed?
  end

  private

  def is_subscribed?
    resource.poll_unsubscriptions.find_by(user: current_user).blank?
  end
end
