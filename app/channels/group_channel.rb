class GroupChannel < ApplicationCable::Channel
  def subscribed
    group = ModelLocator.new(:group, params).locate
    stream_from group.message_channel if current_user.ability.can?(:subscribe_to, group)
  end
end
