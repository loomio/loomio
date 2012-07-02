class Event < ActiveRecord::Base
  KINDS = ["new_discussion", "new_comment", "new_motion", "new_vote"]

  has_many :notifications
  belongs_to :discussion
  belongs_to :comment
  belongs_to :motion

  validates_inclusion_of :kind, :in => KINDS

  attr_accessible :kind, :discussion, :comment, :motion

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
      unless user == comment.user
        notification = event.notifications.create! :user => user
      end
    end
    event
  end

  def self.new_motion!(motion)
    event = create!(:kind => "new_motion", :motion => motion)
    motion.group.users.each do |user|
      unless user == motion.author
        event.notifications.create! :user => user
      end
    end
    event
  end

  def self.new_vote!(vote)
    #event = create!(:kind => "new_vote", :vote => vote)
    #unless user == vote.motion.author
      #event.notifications.create! :user => vote.motion.author
    #end
    #unless user == vote.discussion.author
    #vote.motion.author.each do |user|
    #event
  end
end
