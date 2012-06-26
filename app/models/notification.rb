class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  validates_presence_of :user, :event

  attr_accessible :user

  default_scope order("id DESC")

  def discussion
    event.discussion
  end
end
