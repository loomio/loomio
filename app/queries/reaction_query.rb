class ReactionQuery
  def self.start
    Reaction.includes(:user)
  end

  def self.visible_where(user: LoggedOutUser.new, params:)
    ids_requested = {
      comment_ids:    Array(params[:comment_ids]),
      discussion_ids: Array(params[:discussion_ids]),
      outcome_ids:    Array(params[:outcome_ids]),
      poll_ids:       Array(params[:poll_ids]),
      stance_ids:     Array(params[:stance_ids])
    }

    comment_topic_ids = Comment.joins(:topic_items)
                               .where(comments: { id: ids_requested[:comment_ids] })
                               .where.not(topic_items: { topic_id: nil })
                               .distinct
                               .pluck('topic_items.topic_id')
    topic_ids_visible = TopicQuery.visible_to(user: user)
                                  .where(id: comment_topic_ids)
                                  .except(:includes)
                                  .ids

    discussion_ids_visible = TopicQuery.visible_to(user: user)
                                       .where(
                                         topicable_type: 'Discussion',
                                         topicable_id: ids_requested[:discussion_ids]
                                       )
                                       .except(:includes)
                                       .pluck(:topicable_id)

    poll_ids_requested = ids_requested[:poll_ids]
    poll_ids_requested += Outcome.where(id: ids_requested[:outcome_ids]).pluck(:poll_id)
    poll_ids_requested += Stance.where(id: ids_requested[:stance_ids]).pluck(:poll_id)
    poll_ids_visible = PollQuery.visible_to(user: user)
                                .where(id: poll_ids_requested.uniq)
                                .except(:includes)
                                .ids
    stance_ids_visible = Stance.joins(:poll)
                               .where(id: ids_requested[:stance_ids], poll_id: poll_ids_visible)
                               .where(
                                 "polls.hide_results != :until_closed OR polls.closed_at IS NOT NULL OR " \
                                 "stances.participant_id = :user_id",
                                 until_closed: Poll.hide_results[:until_closed],
                                 user_id: user.id || 0
                               )
                               .ids

    unsafe_where(
      comment_ids: Comment.joins(:topic_items)
                          .where(comments: { id: ids_requested[:comment_ids] })
                          .where(topic_items: { topic_id: topic_ids_visible })
                          .distinct
                          .ids,
      discussion_ids: discussion_ids_visible,
      outcome_ids: Outcome.where(id: ids_requested[:outcome_ids], poll_id: poll_ids_visible).ids,
      poll_ids: ids_requested[:poll_ids] & poll_ids_visible,
      stance_ids: stance_ids_visible
    )
  end

  def self.unsafe_where(params)
    ids = {
      discussion_ids: Array(params[:discussion_ids]),
      outcome_ids:    Array(params[:outcome_ids]),
      comment_ids:    Array(params[:comment_ids]),
      poll_ids:       Array(params[:poll_ids]),
      stance_ids:     Array(params[:stance_ids])
    }
    Reaction.where(
      "(reactable_type = 'Discussion' AND reactable_id IN (:discussion_ids)) OR
       (reactable_type = 'Comment'    AND reactable_id IN (:comment_ids)) OR
       (reactable_type = 'Outcome'    AND reactable_id IN (:outcome_ids)) OR
       (reactable_type = 'Stance'     AND reactable_id IN (:stance_ids)) OR
       (reactable_type = 'Poll'       AND reactable_id IN (:poll_ids))", ids)
  end

  private_class_method :unsafe_where
end
