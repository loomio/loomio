class PollsController < ApplicationController
  include UsesMetadata

  def share
    current_user.ability.authorize! :share, resource
    show
  end

  private

  def metadata_user
    current_user.presence || community_bot_user || LoggedOutUser.new
  end

  def community_bot_user
    return unless params[:identifier]
    Communities::Base.with_identity.find_by(identifier: params[:identifier])&.user
  end
end
