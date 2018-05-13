class MembershipChannel < ApplicationCable::Channel
  def subscribed
    membership = Membership.find_by(token: current_user.token)
    stream_from membership.message_channel if membership
  end
end
