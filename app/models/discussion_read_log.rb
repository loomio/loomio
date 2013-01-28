class DiscussionReadLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :discussion
  validates_presence_of :discussion_last_viewed_at, :discussion_id, :user_id
  validates_uniqueness_of :user_id, :scope => :discussion_id

  before_validation :set_discussion_last_viewed_at_to_now, :on => :create

  private

  def set_discussion_last_viewed_at_to_now
    self.discussion_last_viewed_at = Time.now
  end
end
