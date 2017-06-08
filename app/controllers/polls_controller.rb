class PollsController < ApplicationController
  include UsesMetadata

  def example
    if poll = PollGenerator.new(params[:type]).generate!
      redirect_to poll_path(poll, participation_token: poll.visitors.first.participation_token)
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

  def metadata_user
    current_user.presence || community_bot_user || LoggedOutUser.new
  end

  def community_bot_user
    return unless params[:identifier]
    Communities::Base.with_identity.find_by(identifier: params[:identifier])&.user
  end
end
