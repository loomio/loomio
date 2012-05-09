class DidNotVote < ActiveRecord::Base
  belongs_to :user
  belongs_to :motion
  validates_uniqueness_of :user_id, :scope => :motion_id
  validates_presence_of :user, :motion
end
