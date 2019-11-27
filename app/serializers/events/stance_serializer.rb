class Events::StanceSerializer < Events::BaseSerializer
  def include_actor?
    scope && object.eventable.participant_for_client(user: scope[:current_user]).presence
  end
end
