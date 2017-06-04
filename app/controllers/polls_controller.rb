class PollsController < ApplicationController
  include UsesMetadata

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
