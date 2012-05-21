class MotionReadLog < ActiveRecord::Base
  #
  # DEPRICATION WARNING:
  # ---
  # This file only exists to make the migrations work
  # It will be deleted soon
  #
  belongs_to :user
  belongs_to :motion
  validates_presence_of :vote_activity_when_last_read, :discussion_activity_when_last_read, :motion_id, :user_id
  validates_uniqueness_of :user_id, :scope => :motion_id
end
