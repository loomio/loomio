class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  validates_presence_of :user, :event

  attr_accessible :user

  def discussion
    event.discussion
  end
end
