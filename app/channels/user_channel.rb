class UserChannel < ApplicationCable::Channel
  def subscribed
    stream_from current_user.message_channel if current_user.is_logged_in?
  end
end
