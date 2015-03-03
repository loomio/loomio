class UsersToEmailQuery
  def self.new_comment(comment)
    discussion = comment.discussion

    users_with_email_enabled(discussion).
      without(comment.author).
      without(comment.mentioned_group_members).
      without(comment.parent_author)
  end

  def self.new_vote(vote)
    users_with_email_enabled(vote.motion.discussion).without(vote.author)
  end

  def self.new_discussion(discussion)
    users = []
    users += users_with_email_enabled(discussion)
    users += User.email_new_discussions_for(discussion.group)
    users.compact.uniq
  end

  def self.new_motion(motion)
    users = []
    users += users_with_email_enabled(motion.discussion)
    users += User.email_new_proposals_for(discussion.group)
    users.compact.uniq
  end

  def self.motion_closing_soon(motion)
    users = []
    users += users_with_email_enabled(motion.discussion)
    users += motion.group_members.email_when_proposal_closing_soon
    users.compact.uniq
  end

  def self.motion_outcome(motion)
    users_with_email_enabled(motion.discussion).without(motion.outcome_author)
  end

  def self.motion_closed(motion)
    users_with_email_enabled(motion.discussion)
  end

  private
  def self.users_with_email_enabled(discussion)
    User.
      active.
      joins("LEFT OUTER JOIN discussion_readers dr ON (dr.user_id = users.id AND dr.discussion_id = #{discussion.id})").
      joins("LEFT OUTER JOIN memberships m ON (m.user_id = users.id AND m.group_id = #{discussion.group_id})").
      where('dr.volume = :email OR (dr.volume IS NULL AND m.volume = :email)', { email: DiscussionReader.volumes[:email] })
  end
end
