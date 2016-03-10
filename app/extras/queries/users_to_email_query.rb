class UsersToEmailQuery
  def self.new_comment(comment)
    UsersByVolumeQuery.loud(comment.discussion).
                       distinct.
                       without(comment.author).
                       without(comment.mentioned_group_members).
                       without(comment.parent_author)
  end

  def self.new_vote(vote)
    UsersByVolumeQuery.loud(vote.motion.discussion).
                       distinct.
                       without(vote.author)
  end

  def self.new_discussion(discussion)
    UsersByVolumeQuery.normal_or_loud(discussion).
                       distinct.
                       without(discussion.author)
  end

  def self.new_motion(motion)
    UsersByVolumeQuery.normal_or_loud(motion.discussion).
                       distinct.
                       without(motion.author)
  end

  def self.motion_closing_soon(motion)
    User.distinct.where.any_of(UsersByVolumeQuery.normal_or_loud(motion.discussion),
                               User.email_proposal_closing_soon_for(motion.group))
  end

  def self.motion_outcome_created(motion)
    UsersByVolumeQuery.normal_or_loud(motion.discussion).
                       distinct.
                       without(motion.outcome_author)
  end

  def self.motion_closed(motion)
    UsersByVolumeQuery.loud(motion.discussion).distinct
  end
end
