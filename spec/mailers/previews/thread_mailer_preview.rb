class ThreadMailerPreview < ActionMailer::Preview
  def new_discussion
    user = FactoryGirl.create(:user)
    discussion = FactoryGirl.create(:discussion)
    ThreadMailer.new_discussion(discussion, user)
  end

  def mentioned
    user = FactoryGirl.create(:user)
    discussion = FactoryGirl.create(:discussion)
    comment = FactoryGirl.create(:comment, discussion: discussion, body: "Hey there @#{user.username}, I love what you said and want to find out more about the stuff you mentioned, can we please have a cup of tea and a bike ride with me?")
    ThreadMailer.mentioned(user, comment)
  end

  def motion_closing_soon
    user = FactoryGirl.create(:user)
    motion = FactoryGirl.create(:motion)
    motion.group.add_member!(user)
    ThreadMailer.motion_closing_soon(user, motion)
  end
end