class Events::CommentVoteSerializer < Events::BaseSerializer
  def eventable
    object.eventable.comment # because the client doesn't know about comment_votes
  end
end
