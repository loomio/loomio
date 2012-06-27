class Event < ActiveRecord::Base
  KINDS = ["new_discussion", "new_comment"]

  has_many :notifications
  belongs_to :discussion
  belongs_to :comment

  validates_inclusion_of :kind, :in => KINDS

  attr_accessible :kind, :discussion, :comment

  def self.new_discussion!(discussion)
    event = create!(:kind => "new_discussion", :discussion => discussion)
    discussion.group.users.each do |user|
      unless user == discussion.author
        event.notifications.create! :user => user
      end
    end
    event
  end

  def self.new_comment!(comment)
    event = create!(:kind => "new_comment", :comment => comment)
    comment.discussion.author_and_participants.each do |user|
      notification = event.notifications.create! :user => user
    end
    event
  end
end
