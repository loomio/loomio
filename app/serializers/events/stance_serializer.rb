class Events::StanceSerializer < Events::BaseSerializer
  def include_actor_id?
    include_actor?
  end

  def include_actor?
    super && !eventable.poll.anonymous
  end
end
