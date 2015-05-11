class ThreadMailerPreview < ActionMailer::Preview
  def new_discussion
    group = FactoryGirl.create :group
    user = FactoryGirl.create :user
    discussion = FactoryGirl.create :discussion, group: group, uses_markdown: true
    event = Events::NewDiscussion.create(kind: 'new_discussion', eventable: discussion, discussion_id: discussion.id)
    group.add_member! user
    ThreadMailer.new_discussion user, event
  end

  def new_comment_followed
    group = FactoryGirl.create :group
    user = FactoryGirl.create :user
    discussion = FactoryGirl.create :discussion, group: group, uses_markdown: true
    DiscussionReader.for(user: user, discussion: discussion).set_volume! :loud
    group.add_member! user
    rich_text_body = "I am a comment with a **bold bit**"
    comment = FactoryGirl.create :comment, discussion: discussion, body: rich_text_body, uses_markdown: true
    event = Events::NewComment.create(kind: 'new_comment', eventable: comment, discussion_id: discussion.id)
    ThreadMailer.new_comment user, event
  end

  def new_comment_with_attachments_followed
    group = FactoryGirl.create :group
    user = FactoryGirl.create :user
    discussion = FactoryGirl.create :discussion, group: group, uses_markdown: true
    DiscussionReader.for(user: user, discussion: discussion).set_volume! :loud
    group.add_member! user
    rich_text_body = "I am a comment with a **bold bit**"
    attachment = FactoryGirl.create :attachment
    second_attachment = FactoryGirl.create :attachment
    comment = FactoryGirl.create :comment, discussion: discussion, body: rich_text_body, uses_markdown: true
    comment.attachments << attachment
    comment.attachments << second_attachment
    event = Events::NewComment.create(kind: 'new_comment', eventable: comment, discussion_id: discussion.id)
    ThreadMailer.new_comment user, event
  end

  def user_mentioned_follows_by_loud
    group = FactoryGirl.create :group
    user = FactoryGirl.create :user
    discussion = FactoryGirl.create :discussion, group: group, uses_markdown: true
    DiscussionReader.for(user: user, discussion: discussion).set_volume! :loud
    group.add_member! user
    rich_text_body = "I like to talk about you online. You're the right person for this conversation to include. You know this."
    comment = FactoryGirl.create :comment, discussion: discussion, body: rich_text_body, uses_markdown: true
    event = Events::UserMentioned.create(kind: 'user_mentioned', eventable: comment)
    ThreadMailer.user_mentioned user, event
  end

  def user_mentioned_does_not_follow_by_loud
    group = FactoryGirl.create :group
    user = FactoryGirl.create :user
    discussion = FactoryGirl.create :discussion, group: group, uses_markdown: true
    group.add_member! user
    rich_text_body = "I like to talk about you online. You're the right person for this conversation to include. You know this."
    comment = FactoryGirl.create :comment, discussion: discussion, body: rich_text_body, uses_markdown: true
    event = Events::UserMentioned.create(kind: 'user_mentioned', eventable: comment)
    ThreadMailer.user_mentioned user, event
  end

  def new_vote_followed
    group = FactoryGirl.create :group
    user = FactoryGirl.create :user
    discussion = FactoryGirl.create :discussion, group: group
    DiscussionReader.for(user: user, discussion: discussion).set_volume! :loud
    group.add_member! user
    motion = FactoryGirl.create :motion, discussion: discussion
    vote = FactoryGirl.create :vote, motion: motion
    event = Events::NewVote.create(kind: 'new_vote', eventable: vote, discussion_id: discussion)
    ThreadMailer.new_vote user, event
  end

  def new_motion_not_followed
    group = FactoryGirl.create :group
    user = FactoryGirl.create :user
    discussion = FactoryGirl.create :discussion, group: group
    group.add_member! user
    motion = FactoryGirl.create :motion, discussion: discussion
    event = Events::NewMotion.create(kind: 'new_motion', eventable: motion, discussion_id: discussion)
    ThreadMailer.new_motion user, event
  end

  def new_motion_followed
    group = FactoryGirl.create :group
    user = FactoryGirl.create :user
    discussion = FactoryGirl.create :discussion, group: group
    DiscussionReader.for(user: user, discussion: discussion).set_volume! :loud
    group.add_member! user
    motion = FactoryGirl.create :motion, discussion: discussion
    event = Events::NewMotion.create(kind: 'new_motion', eventable: motion, discussion_id: discussion)
    ThreadMailer.new_motion user, event
  end

  def motion_closing_soon_followed
    group = FactoryGirl.create :group
    user = FactoryGirl.create :user
    discussion = FactoryGirl.create :discussion, group: group
    DiscussionReader.for(user: user, discussion: discussion).set_volume! :loud
    group.add_member! user
    motion = FactoryGirl.create :motion, discussion: discussion

    event = Events::MotionClosingSoon.create(kind: 'motion_closing_soon',
                                             eventable: motion,
                                             discussion_id: motion.discussion.id)

    ThreadMailer.motion_closing_soon user, event
  end

  def motion_closing_soon_not_followed
    group = FactoryGirl.create :group
    user = FactoryGirl.create :user
    discussion = FactoryGirl.create :discussion, group: group
    group.add_member! user
    motion = FactoryGirl.create :motion, discussion: discussion
    event = Events::MotionClosingSoon.create(kind: 'motion_closing_soon',
                                             eventable: motion,
                                             discussion_id: motion.discussion.id)
    ThreadMailer.motion_closing_soon user, event
  end

  def motion_closed_following
    group = FactoryGirl.create :group
    user = FactoryGirl.create :user
    discussion = FactoryGirl.create :discussion, group: group
    DiscussionReader.for(user: user, discussion: discussion).set_volume! :loud
    group.add_member! user
    motion = FactoryGirl.create :motion, discussion: discussion
    vote = FactoryGirl.create :vote, motion: motion
    vote = FactoryGirl.create :vote, motion: motion
    vote = FactoryGirl.create :vote, motion: motion
    motion.store_users_that_didnt_vote
    motion.closed_at = Time.now
    motion.save!
    event = Events::MotionClosed.create(kind: 'motion_closed',
                                        eventable: motion,
                                        discussion_id: motion.discussion.id)
    ThreadMailer.motion_closed user, event
  end

  def specify_motion_outcome
    group = FactoryGirl.create :group
    user = FactoryGirl.create :user
    discussion = FactoryGirl.create :discussion, group: group
    DiscussionReader.for(user: user, discussion: discussion).set_volume! :loud
    group.add_member! user
    motion = FactoryGirl.create :motion, discussion: discussion, author: user
    vote = FactoryGirl.create :vote, motion: motion
    vote = FactoryGirl.create :vote, motion: motion
    vote = FactoryGirl.create :vote, motion: motion
    motion.store_users_that_didnt_vote
    motion.closed_at = Time.now
    motion.save!
    event = Events::MotionOutcomeCreated.create(kind: "motion_outcome_created",
                                                eventable: motion,
                                                discussion_id: motion.discussion.id,
                                                user: user)
    ThreadMailer.motion_closed motion.author, event
  end

  def motion_outcome_created
    motion = FactoryGirl.create(:motion)
    group = motion.group
    user = FactoryGirl.create(:user)
    group.add_member!(user)
    motion.store_users_that_didnt_vote
    motion.closed_at = Time.now
    motion.outcome = "the motion was voted upon variously, hurrah"
    motion.outcome_author = motion.author
    motion.save!

    event = Events::MotionOutcomeCreated.create(kind: "motion_outcome_created",
                                                eventable: motion,
                                                discussion_id: motion.discussion.id,
                                                user: user)
    ThreadMailer.motion_outcome_created user, event
  end
end
