class MotionActivityReadLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :motion
  validates_presence_of :last_read_at, :motion_id, :user_id
  validates_uniqueness_of :user_id, :scope => :motion_id
end
