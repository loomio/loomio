class Activity < ActiveRecord::Base
  belongs_to :user
  #has_one :user, :motion
  validates_presence_of :user_id, :motion_id, :activity_count
end
