class ThreadMailerQuery
  def self.users_to_email_new_comment(comment)
    discussion = comment.discussion

    users_with_volume_email(discussion).
      without(comment.author).
      without(comment.mentioned_group_members).
      without(comment.parent_author)
  end

  def self.users_to_email_new_vote(vote)
    users_with_volume_email(vote.motion.discussion).without(vote.author)
  end

  def self.users_to_email_new_discussion(discussion)
    users = []
    users += users_with_volume_email(discussion)
    users += User.email_new_discussions_for(discussion.group)
    users.compact.uniq
  end

  def self.users_to_email_new_motion(motion)
    users = []
    users += users_with_volume_email(motion.discussion)
    users += User.email_new_proposals_for(discussion.group)
    users.compact.uniq
  end

  def self.users_to_email_motion_closing_soon(motion)
    users = []
    users += users_with_volume_email(motion.discussion)
    users += motion.group_members.email_when_proposal_closing_soon
    users.compact.uniq
  end

  def self.users_to_email_motion_outcome(motion)
    users_with_volume_email(motion.discussion).without(motion.outcome_author)
  end

  def self.users_with_volume_email(discussion)
    User.
      active.
      joins("LEFT OUTER JOIN discussion_readers dr ON (dr.user_id = users.id AND dr.discussion_id = #{discussion.id})").
      joins("LEFT OUTER JOIN memberships m ON (m.user_id = users.id AND m.group_id = #{discussion.group_id})").
      where('dr.volume = :email OR (dr.volume IS NULL AND m.volume = :email)', { email: DiscussionReader.volumes[:email] })
  end
end
