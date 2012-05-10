class DiscussionReadLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :discussion
  validates_presence_of :discussion_activity_when_last_read, :discussion_id, :user_id
  validates_uniqueness_of :user_id, :scope => :discussion_id
end
