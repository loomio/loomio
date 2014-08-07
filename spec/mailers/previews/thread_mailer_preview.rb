class ThreadMailerPreview < ActionMailer::Preview
  def new_discussion
    user = FactoryGirl.create(:user)
    discussion = FactoryGirl.create(:discussion)
    ThreadMailer.new_discussion(discussion, user)
  end

  def new_comment
    user = FactoryGirl.create :user
    discussion = FactoryGirl.create :discussion
    rich_text_body = "I am a comment with a **bold bit**"
    comment = FactoryGirl.create :comment, discussion: discussion, body: rich_text_body, uses_markdown: true
    ThreadMailer.new_comment comment, user
  end

  def new_vote
    user = FactoryGirl.create :user
    motion = FactoryGirl.create :motion
    vote = FactoryGirl.create :vote, motion: motion
    ThreadMailer.new_vote vote, user
  end

  def new_motion
    user = FactoryGirl.create :user
    motion = FactoryGirl.create :motion
    ThreadMailer.new_motion motion, user
  end

  def motion_closing_soon
    user = FactoryGirl.create :user
    motion = FactoryGirl.create :motion
    ThreadMailer.motion_closing_soon motion, user
  end
end