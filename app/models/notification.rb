class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  validates_presence_of :user, :event
  validates_uniqueness_of :user_id, :scope => :event_id

  attr_accessible :user, :event

  default_scope order("id DESC")

  def discussion
    event.discussion
  end

  def comment
    event.comment
  end

  def motion
    event.motion
  end

  def vote
    event.vote
  end
end
