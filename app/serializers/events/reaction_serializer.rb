class Events::ReactionSerializer < Events::BaseSerializer
  def eventable
    object.eventable.reactable # because the client doesn't know about reactions
  end
end
