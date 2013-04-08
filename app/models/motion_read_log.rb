class MotionReadLog < ActiveRecord::Base
  attr_accessible :user_id, :motion_id, :motion_last_viewed_at

  belongs_to :user
  belongs_to :motion
  validates_presence_of :motion_last_viewed_at, :motion_id, :user_id
  validates_uniqueness_of :user_id, scope: :motion_id

  before_validation :set_motion_last_viewed_at_to_now, on: :create

  private

  def set_motion_last_viewed_at_to_now
    self.motion_last_viewed_at = Time.now
  end
end