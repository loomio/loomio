class Notification < ActiveRecord::Base
  KINDS = ["new_discussion"]

  belongs_to :user
  belongs_to :discussion
  belongs_to :comment
  belongs_to :motion

  validates_presence_of :kind
  validates_inclusion_of :kind, :in => KINDS

  attr_accessible :user, :kind, :discussion, :comment, :motion
end
