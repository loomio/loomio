class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :discussion
  belongs_to :comment
  belongs_to :motion

  validates_presence_of :kind
  validates_inclusion_of :kind, :in => Event::KINDS

  attr_accessible :user, :kind, :discussion, :comment, :motion
end
