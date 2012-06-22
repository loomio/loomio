class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :discussion
  belongs_to :comment
  belongs_to :motion

  validates_presence_of :kind
  validates_inclusion_of :kind, :in => Event::KINDS

  attr_accessible :user, :kind, :discussion, :comment, :motion

  def self.new_discussion!(discussion, user)
    Notification.create!(kind: "new_discussion", user: user, discussion: discussion)
  end
end
