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
                       without(discussion.author).
                       without(discussion.mentioned_group_members)
  end

  def self.new_motion(motion)
    Queries::UsersByVolumeQuery.normal_or_loud(motion.discussion).
                       distinct.
                       without(motion.author).
                       without(motion.mentioned_group_members)
  end

  def self.motion_closing_soon(motion)
    User.distinct.where.any_of(Queries::UsersByVolumeQuery.normal_or_loud(motion.discussion),
                               User.email_proposal_closing_soon_for(motion.group))
  end

  def self.motion_outcome_created(motion)
    Queries::UsersByVolumeQuery.normal_or_loud(motion.discussion).
                       distinct.
                       without(motion.outcome_author)
  end

  def self.motion_closed(motion)
    Queries::UsersByVolumeQuery.normal_or_loud(motion.discussion).distinct
  end

  def self.new_poll(event)
    return User.none unless event.announcement
    event.eventable.watchers
         .without(event.user)
  end

  def self.poll_edited(event)
    return User.none unless event.announcement
    event.eventable.participants
  end

  def self.poll_closing_soon(event)
    event.eventable.watchers
         .without(event.eventable.participants)
         .without(event.eventable.author)
  end

  def self.new_outcome(event)
    return User.none unless event.announcement
    event.eventable.poll.watchers
         .without(event.user) # maybe just poll participants?
  end
end
