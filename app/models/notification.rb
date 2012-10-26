class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  validates_presence_of :user, :event
  validates_uniqueness_of :user_id, :scope => :event_id

  delegate :kind, :to => :event, :prefix => :event
  delegate :eventable, :to => :event

  attr_accessible :user, :event

  default_scope order("id DESC")

  scope :unviewed, where("viewed_at IS NULL")

  def method_missing method_name, *args
    name = method_name.to_s
    if name =~ /^(discussion|comment|motion|vote|membership|comment_vote|user_mentioned)$/
      event.eventable if event.eventable_type == name.camelize
    else
      super
    end
  end
end

