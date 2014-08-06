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

  def motion_created
    motion = FactoryGirl.create(:motion)
    group = motion.group
    user = FactoryGirl.create(:user)
    group.add_member!(user)
    ThreadMailer.motion_created(motion, user)
  end

  def motion_blocked
    motion = FactoryGirl.create(:motion)
    vote = FactoryGirl.create(:vote, motion: motion, position: 'block')
    ThreadMailer.motion_blocked(vote)
  end

  def motion_closing_soon
    user = FactoryGirl.create(:user)
    motion = FactoryGirl.create(:motion)
    motion.group.add_member!(user)
    ThreadMailer.motion_closing_soon(user, motion)
  end

  def motion_closed
    motion = FactoryGirl.create(:motion)
    motion.store_users_that_didnt_vote
    motion.closed_at = Time.now
    motion.save!
    ThreadMailer.motion_closed(motion, motion.author.email)
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
    ThreadMailer.motion_outcome_created(motion, user)
  end
end