class PollChannel < ApplicationCable::Channel
  def subscribed
    poll = ModelLocator.new(:poll, params).locate
    stream_from poll.message_channel if current_user.ability.can?(:subscribe_to, poll)
  end
end
