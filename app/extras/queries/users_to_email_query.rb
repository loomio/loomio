class Queries::UsersToEmailQuery
  def self.new_comment(comment)
    Queries::UsersByVolumeQuery.loud(comment.discussion).
                       distinct.
                       without(comment.author).
                       without(comment.mentioned_group_members).
                       without(comment.parent_author)
  end

  def self.new_vote(vote)
    Queries::UsersByVolumeQuery.loud(vote.motion.discussion).
                       distinct.
                       without(vote.author)
  end

  def self.new_discussion(discussion)
    Queries::UsersByVolumeQuery.normal_or_loud(discussion).
                       distinct.
                       without(discussion.author)
  end

  def self.new_motion(motion)
    Queries::UsersByVolumeQuery.normal_or_loud(motion.discussion).
                       distinct.
                       without(motion.author)
  end

  def self.motion_closing_soon(motion)
    User.distinct.from("(#{Queries::UsersByVolumeQuery.normal_or_loud(motion.discussion).to_sql} UNION
                         #{User.email_proposal_closing_soon_for(motion.group).to_sql}) as users")
  end

  def self.motion_outcome_created(motion)
    Queries::UsersByVolumeQuery.normal_or_loud(motion.discussion).
                       distinct.
                       where.not(id: motion.outcome_author.id)
  end

  def self.motion_closed(motion)
    Queries::UsersByVolumeQuery.normal_or_loud(motion.discussion).distinct
  end
end
