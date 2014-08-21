class ThreadMailerPreview < ActionMailer::Preview
  def new_discussion
    group = FactoryGirl.create :group
    user = FactoryGirl.create :user
    group.add_member! user
    discussion = FactoryGirl.create :discussion, group: group, uses_markdown: true
    ThreadMailer.new_discussion user, discussion
  end

  def new_comment
    user = FactoryGirl.create :user
    discussion = FactoryGirl.create :discussion
    rich_text_body = "I am a comment with a **bold bit**"
    comment = FactoryGirl.create :comment, discussion: discussion, body: rich_text_body, uses_markdown: true
    ThreadMailer.new_comment user, comment
  end

  def new_vote
    user = FactoryGirl.create :user
    motion = FactoryGirl.create :motion
    vote = FactoryGirl.create :vote, motion: motion
    ThreadMailer.new_vote user, vote
  end

  def new_motion
    user = FactoryGirl.create :user
    motion = FactoryGirl.create :motion
    ThreadMailer.new_motion user, motion
  end

  def motion_closing_soon
    user = FactoryGirl.create :user
    motion = FactoryGirl.create :motion
    ThreadMailer.motion_closing_soon user, motion
  end
end