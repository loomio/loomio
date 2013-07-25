class Events::MotionBlocked < Event
  after_create :notify_users!

  def self.publish!(vote)
    create!(kind: "motion_blocked", eventable: vote,
            discussion_id: vote.motion.discussion.id)
  end

  def vote
    eventable
  end

  private

  def notify_users!
    vote.other_group_members.each do |user|
      notify!(user)
    end
  end

  handle_asynchronously :notify_users!
end
