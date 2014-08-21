class ThreadMailerPreview < ActionMailer::Preview
  def new_discussion
    group = FactoryGirl.create :group
    user = FactoryGirl.create :user
    discussion = FactoryGirl.create :discussion, group: group, uses_markdown: true
    group.add_member! user
    ThreadMailer.new_discussion user, discussion
  end

  def new_comment_followed
    group = FactoryGirl.create :group
    user = FactoryGirl.create :user
    discussion = FactoryGirl.create :discussion, group: group, uses_markdown: true
    DiscussionReader.for(user: user, discussion: discussion).follow!
    group.add_member! user
    rich_text_body = "I am a comment with a **bold bit**"
    comment = FactoryGirl.create :comment, discussion: discussion, body: rich_text_body, uses_markdown: true
    ThreadMailer.new_comment user, comment
  end

  def new_vote_followed
    group = FactoryGirl.create :group
    user = FactoryGirl.create :user
    discussion = FactoryGirl.create :discussion, group: group
    DiscussionReader.for(user: user, discussion: discussion).follow!
    group.add_member! user
    motion = FactoryGirl.create :motion, discussion: discussion
    vote = FactoryGirl.create :vote, motion: motion
    ThreadMailer.new_vote user, vote
  end

  def new_motion_not_followed
    group = FactoryGirl.create :group
    user = FactoryGirl.create :user
    discussion = FactoryGirl.create :discussion, group: group
    group.add_member! user
    motion = FactoryGirl.create :motion, discussion: discussion
    ThreadMailer.new_motion user, motion
  end

  def new_motion_followed
    group = FactoryGirl.create :group
    user = FactoryGirl.create :user
    discussion = FactoryGirl.create :discussion, group: group
    DiscussionReader.for(user: user, discussion: discussion).follow!
    group.add_member! user
    motion = FactoryGirl.create :motion, discussion: discussion
    ThreadMailer.new_motion user, motion
  end

  def motion_closing_soon_followed
    group = FactoryGirl.create :group
    user = FactoryGirl.create :user
    discussion = FactoryGirl.create :discussion, group: group
    DiscussionReader.for(user: user, discussion: discussion).follow!
    group.add_member! user
    motion = FactoryGirl.create :motion, discussion: discussion
    ThreadMailer.motion_closing_soon user, motion
  end

  def motion_closing_soon_not_followed
    group = FactoryGirl.create :group
    user = FactoryGirl.create :user
    discussion = FactoryGirl.create :discussion, group: group
    group.add_member! user
    motion = FactoryGirl.create :motion, discussion: discussion
    ThreadMailer.motion_closing_soon user, motion
  end

  def motion_closed_following
    group = FactoryGirl.create :group
    user = FactoryGirl.create :user
    discussion = FactoryGirl.create :discussion, group: group
    DiscussionReader.for(user: user, discussion: discussion).follow!
    group.add_member! user
    motion = FactoryGirl.create :motion, discussion: discussion
    vote = FactoryGirl.create :vote, motion: motion
    vote = FactoryGirl.create :vote, motion: motion
    vote = FactoryGirl.create :vote, motion: motion
    motion.store_users_that_didnt_vote
    motion.closed_at = Time.now
    motion.save!
    ThreadMailer.motion_closed user, motion
  end

  def specify_motion_outcome
    group = FactoryGirl.create :group
    user = FactoryGirl.create :user
    discussion = FactoryGirl.create :discussion, group: group
    DiscussionReader.for(user: user, discussion: discussion).follow!
    group.add_member! user
    motion = FactoryGirl.create :motion, discussion: discussion, author: user
    vote = FactoryGirl.create :vote, motion: motion
    vote = FactoryGirl.create :vote, motion: motion
    vote = FactoryGirl.create :vote, motion: motion
    motion.store_users_that_didnt_vote
    motion.closed_at = Time.now
    motion.save!
    ThreadMailer.motion_closed motion.author, motion
  end

  def motion_outcome_created
    motion = FactoryGirl.create(:motion)
    group = motion.group
    user = FactoryGirl.create(:user)
    group.add_member!(user)
    motion.store_users_that_didnt_vote
    motion.closed_at = Time.now
    motion.save!
    motion.outcome = "the motion was voted upon variously, hurrah"
    motion.outcome_author = motion.author
    ThreadMailer.motion_outcome_created user, motion
  end
end