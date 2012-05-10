class AddColumnDiscussionIdToMotionReadLog < ActiveRecord::Migration
  def up
    add_column :motion_read_logs, :discussion_id, :integer
    MotionReadLog.reset_column_information
    MotionReadLog.all.each do |log|
      motion = Motion.find_by_id(log.motion_id)
      if motion
        log.discussion_id = motion.discussion_id
        log.save
      else
        log.delete
      end
    end
    remove_column :motion_read_logs, :motion_id
    add_index :motion_read_logs, :discussion_id
  end

  def down
    add_column :motion_read_logs, :motion_id, :integer
    MotionReadLog.reset_column_information
    MotionReadLog.all.each do |log|
      motion = Motion.find(log.discussion_id)
      log.motion_id = motion.id unless motion.nil?
      log.save!
    end
    remove_column :motion_read_logs, :discussion_id
  end
end
