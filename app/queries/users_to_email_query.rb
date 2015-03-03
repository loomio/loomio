class UsersToEmailQuery
  def self.new_comment(comment)
    discussion = comment.discussion

    UsersByThreadVolumeQuery.email(discussion).
                             without(comment.author).
                             without(comment.mentioned_group_members).
                             without(comment.parent_author)

  end

  def self.new_vote(vote)
    UsersByThreadVolumeQuery.email(vote.motion.discussion).without(vote.author)
  end

  def self.new_discussion(discussion)
    User.where.any_of(UsersByThreadVolumeQuery.email(discussion),
                      User.email_new_discussions_for(discussion.group))
              .without(discussion.author)
  end

  def self.new_motion(motion)
    User.where.any_of(UsersByThreadVolumeQuery.email(motion.discussion),
                      User.email_new_discussions_for(motion.discussion.group))
              .without(motion.author)
  end

  def self.motion_closing_soon(motion)
    User.where.any_of(UsersByThreadVolumeQuery.email(motion.discussion),
                      User.email_proposal_closing_soon_for(motion.group))
  end

  def self.motion_outcome(motion)
    UsersByThreadVolumeQuery.email(motion.discussion).without(motion.outcome_author)
  end

  def self.motion_closed(motion)
    UsersByThreadVolumeQuery.email(motion.discussion)
  end
end
