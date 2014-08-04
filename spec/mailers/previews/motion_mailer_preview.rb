class MotionMailerPreview < ActionMailer::Preview
  def new_motion_created
    motion = FactoryGirl.create(:motion)
    group = motion.group
    user = FactoryGirl.create(:user)
    group.add_member!(user)
    MotionMailer.new_motion_created(motion, user)
  end

  def motion_closed
    motion = FactoryGirl.create(:motion)
    motion.store_users_that_didnt_vote
    motion.closed_at = Time.now
    motion.save!
    MotionMailer.motion_closed(motion, motion.author.email)
  end

  def motion_blocked
    motion = FactoryGirl.create(:motion)
    vote = FactoryGirl.create(:vote, motion: motion, position: 'block')
    MotionMailer.motion_blocked(vote)
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
    MotionMailer.motion_outcome_created(motion, user)
  end
end
