class Events::StanceSerializer < Events::BaseSerializer
  def include_actor?
    !object.eventable.poll.anonymous || scope[:current_user_id] == object.user_id
  end
end
