class MotionReadLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :motion
  validates_presence_of :motion_activity_when_last_read, :motion_id, :user_id
  validates_uniqueness_of :user_id, :scope => :motion_id
end
