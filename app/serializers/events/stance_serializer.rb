class Events::StanceSerializer < Events::BaseSerializer
  def include_actor?
    super &&
    if eventable.poll.anonymous
      scope && actor == scope[:current_user]
    else
      true
    end
  end
end
