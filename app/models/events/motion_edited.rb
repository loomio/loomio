class Events::MotionEdited < Event
  after_create :notify_users!

  def self.publish!(motion, editor)
    create!(:kind => "motion_edited", :eventable => motion, :user => editor,
                      :discussion_id => motion.discussion.id)
  end

  def motion
    eventable
  end

  private

  def notify_users!
    Queries::Voters.users_that_voted_on(motion).each do |voted_user|
      unless voted_user == user
        MotionMailer.motion_edited(motion, voted_user.email, user).deliver
        notify!(voted_user)
      end
    end
  end

  handle_asynchronously :notify_users!
end
