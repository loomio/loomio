class Events::MotionClosedByUser < Events::MotionClosed
  after_create :notify_users!

  def self.publish!(motion, closer)
    create!(kind: "motion_closed_by_user",
            eventable: motion,
            user: closer,
            discussion: motion.discussion)
  end

  private

  def notify_users!
    motion.group_members.each do |group_user|
      notify!(group_user) unless group_user == user
    end
  end

  handle_asynchronously :notify_users!
end
