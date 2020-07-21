class ReactionQuery
  def self.start
    Reaction.includes(:user)
  end

  def self.authorize!(user: LoggedOutUser.new, chain: start, params: )
    discussion_ids = []
    poll_ids = []

    discussion_ids.concat(Comment.distinct.where(id: params[:comment_ids]).pluck(:discussion_id)) if params[:comment_ids]
    discussion_ids.concat(params[:discussion_ids]) if params[:discussion_ids]

    poll_ids.concat(Outcome.distinct.where(id: params[:outcome_ids]).pluck(:poll_id)) if params[:outcome_ids]
    poll_ids.concat(params[:poll_ids]) if params[:poll_ids]

    discussion_ids.uniq!
    poll_ids.uniq!

    if (PollQuery.visible_to(user: user, show_public: true).where(id: poll_ids).count != poll_ids.length) ||
       (DiscussionQuery.visible_to(user: user).where(id: discussion_ids).count != discussion_ids.length)
      raise CanCan::AccessDenied.new
    end
  end

  def self.unsafe_where(params)
    ids = {
      discussion_ids: Array(params[:discussion_ids]),
      outcome_ids: Array(params[:outcome_ids]),
      comment_ids: Array(params[:comment_ids]),
      poll_ids:    Array(params[:poll_ids])
    }
    Reaction.where(
      "(reactable_type = 'Discussion' AND reactable_id IN (:discussion_ids)) OR
       (reactable_type = 'Comment'    AND reactable_id IN (:comment_ids)) OR
       (reactable_type = 'Outcome'    AND reactable_id IN (:outcome_ids)) OR
       (reactable_type = 'Poll'       AND reactable_id IN (:poll_ids))", ids)
  end
end
