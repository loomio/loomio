class Events::MotionOutcomeUpdated < Event
  # after_create :notify_users!

  def self.publish!(motion, user)
    create!(:kind => "motion_outcome_updated", :eventable => motion,
            :discussion_id => motion.discussion.id, :user => user)
  end

  def motion
    eventable
  end

  private

  # def notify_users!
  #   motion.group_users_without_motion_author.each do |user|
  #     notify!(user)
  #   end
  # end

  # handle_asynchronously :notify_users!
end