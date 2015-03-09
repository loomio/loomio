class UsersToEmailQuery
  def self.new_comment(comment)
    UsersByVolumeQuery.loud(comment.discussion).
                       without(comment.author).
                       without(comment.mentioned_group_members).
                       without(comment.parent_author)
  end

  def self.new_vote(vote)
    UsersByVolumeQuery.loud(vote.motion.discussion).
                       without(vote.author)
  end

  def self.new_discussion(discussion)
    UsersByVolumeQuery.normal_or_loud(discussion).
                       without(discussion.author)
  end

  def self.new_motion(motion)
    UsersByVolumeQuery.normal_or_loud(motion.discussion).
                       without(motion.author)
  end

  def self.motion_closing_soon(motion)
    User.where.any_of(UsersByVolumeQuery.normal_or_loud(motion.discussion),
                      User.email_proposal_closing_soon_for(motion.group))
  end

  def self.motion_outcome(motion)
    UsersByVolumeQuery.normal_or_loud(motion.discussion).
                       without(motion.outcome_author)
  end

  def self.motion_closed(motion)
    UsersByVolumeQuery.loud(motion.discussion)
  end
end
