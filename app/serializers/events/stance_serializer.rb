class Events::StanceSerializer < Events::BaseSerializer
  def include_actor?
    !object.eventable.poll.anonymous || scope[:current_user] == object.user
  end
end
