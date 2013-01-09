class Events::MotionCloseDateEdited < Event
  def self.publish!(motion, editor)
    create!(:kind => "motion_close_date_edited", :eventable => motion,
              :discussion_id => motion.discussion.id, :user => editor)
  end
end