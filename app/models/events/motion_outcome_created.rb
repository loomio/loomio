class Events::MotionOutcomeCreated < Event
  after_create :notify_users!

  def self.publish!(motion, user)
    create!(:kind => "motion_outcome_created", :eventable => motion,
            :discussion_id => motion.discussion.id, :user => user)
  end

  def motion
    eventable
  end

  private

  def notify_users!
    motion.group_members_without_outcome_author.each do |user|
      if user.email_notifications_for_group?(motion.group)
        MotionMailer.motion_outcome_created(motion, user).deliver
      end
      notify!(user)
    end
  end

  handle_asynchronously :notify_users!
end
