class PollsController < ApplicationController
  include UsesMetadata
  include LoadAndAuthorize

  helper :email

  def example
    if poll = PollGenerator.new(params[:type]).generate!
      redirect_to poll_path(poll, invitation_token: poll.guest_invitations.first.token)
    else
      redirect_to root_path, notice: "Sorry, we don't know about that poll type"
    end
  end

  def embed
    @info = PollEmailInfo.new(poll: load_and_authorize(:poll, :embed), action_name: :embed)
    headers.delete 'X-Frame-Options'
    render layout: false
  end

  def unsubscribe
    PollService.toggle_subscription(poll: resource, actor: current_user) if is_subscribed?
  end

  private

  def is_subscribed?
    resource.poll_unsubscriptions.find_by(user: current_user).blank?
  end
end
