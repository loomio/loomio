class ThreadMailerPreview < ActionMailer::Preview
  def setup
  end

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
    user = FactoryGirl.create :user
    motion = FactoryGirl.create :motion
    ThreadMailer.motion_closing_soon user, motion
  end
end