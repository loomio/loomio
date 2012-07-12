class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  validates_presence_of :user, :event
  validates_uniqueness_of :user_id, :scope => :event_id

  delegate :kind, :to => :event, :prefix => :event
  delegate :vote, :discussion, :comment, :motion, :membership, :to => :event

  attr_accessible :user, :event

  default_scope order("id DESC")
end

