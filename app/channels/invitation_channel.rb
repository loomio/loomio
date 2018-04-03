class InvitationChannel < ApplicationCable::Channel
  def subscribed
    invitation = Invitation.find_by(token: current_user.token)
    stream_from invitation.message_channel if invitation
  end
end
