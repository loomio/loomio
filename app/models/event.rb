class Event < ActiveRecord::Base
  KINDS = %w[new_discussion new_comment new_motion new_vote motion_blocked
             membership_requested user_added_to_group]

  has_many :notifications
  belongs_to :discussion
  belongs_to :comment
  belongs_to :motion
  belongs_to :vote
  belongs_to :membership

  validates_inclusion_of :kind, :in => KINDS

  attr_accessible :kind, :discussion, :comment, :motion, :vote, :membership

  def self.new_discussion!(discussion)
    event = create!(:kind => "new_discussion", :discussion => discussion)
    discussion.group_users.each do |user|
      unless user == discussion.author
        event.notifications.create! :user => user
      end
    end
    event
  end

  def self.new_comment!(comment)
    event = create!(:kind => "new_comment", :comment => comment)
    comment.discussion_participants.each do |user|
      unless user == comment.user
        event.notifications.create! :user => user
      end
    end
    event
  end

  def self.new_motion!(motion)
    event = create!(:kind => "new_motion", :motion => motion)
    motion.group_users.each do |user|
      unless user == motion.author
        event.notifications.create! :user => user
      end
    end
    event
  end

  def self.new_vote!(vote)
    event = create!(:kind => "new_vote", :vote => vote)
    begin
      unless vote.user == vote.motion_author
        event.notifications.create! :user => vote.motion_author
      end
      unless vote.user == vote.discussion_author
        event.notifications.create! :user => vote.discussion_author
      end
    rescue ActiveRecord::RecordInvalid => error
      # Catches error if we are trying to create duplicate notifications for
      # the same user (i.e. if motion author and discussion author are same person)
      raise unless error.message =~ /User has already been taken/
    end
    event
  end

  def self.motion_blocked!(vote)
    event = create!(:kind => "motion_blocked", :vote => vote)
    vote.group_users.each do |user|
      unless user == vote.user
        event.notifications.create! :user => user
      end
    end
    event
  end

  def self.membership_requested!(membership)
    event = create!(:kind => "membership_requested", :membership => membership)
    membership.group_admins.each do |admin|
      event.notifications.create! :user => admin
    end
    event
  end

  def self.user_added_to_group!(membership)
    event = create!(:kind => "user_added_to_group", :membership => membership)
    event.notifications.create! :user => membership.user
    # Send email only if the user has already accepted invitation to Loomio
    #if membership.user.accepting_or_not_invited?
      #UserMailer.added_to_group(membership.user, membership.group).deliver
    #end
    UserMailer.added_to_group(membership.user, membership.group).deliver
    event
  end
end
