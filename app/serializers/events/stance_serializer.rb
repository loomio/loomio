class Events::StanceSerializer < Events::BaseSerializer
  def include_actor?
    scope && !eventable.poll.anonymous
  end
end
