class UsersToEmailQuery
  def self.new_comment(comment)
    UsersByVolumeQuery.thread_volume_email(comment.discussion).
                             without(comment.author).
                             without(comment.mentioned_group_members).
                             without(comment.parent_author)

  end

  def self.new_vote(vote)
    UsersByVolumeQuery.thread_volume_email(vote.motion.discussion).
                             without(vote.author)
  end

  def self.new_discussion(discussion)
    UsersByVolumeQuery.membership_volume_email(discussion).
                             without(discussion.author)
  end

  def self.new_motion(motion)
    UsersByVolumeQuery.email(motion.discussion).
                             without(motion.author)
  end

  def self.motion_closing_soon(motion)
    User.where.any_of(UsersByVolumeQuery.thread_volume_email(motion.discussion),
                      User.email_proposal_closing_soon_for(motion.group))
  end

  def self.motion_outcome(motion)
    UsersByVolumeQuery.thread_volume_email(motion.discussion).without(motion.outcome_author)
  end

  def self.motion_closed(motion)
    UsersByVolumeQuery.thread_volume_email(motion.discussion)
  end
end
