class Event < ActiveRecord::Base
  KINDS = %w[new_discussion new_comment new_motion new_vote motion_blocked
             motion_closed membership_requested user_added_to_group comment_liked]

  has_many :notifications, :dependent => :destroy
  belongs_to :eventable, :polymorphic => true
  belongs_to :user

  validates_inclusion_of :kind, :in => KINDS
  validates_presence_of :eventable

  attr_accessible :kind, :eventable, :user

  def self.new_discussion!(discussion)
    event = create!(:kind => "new_discussion", :eventable => discussion)
    discussion.group_users.each do |user|
      unless user == discussion.author
        event.notifications.create! :user => user
      end
    end
    event
  end

  def self.new_comment!(comment)
    event = create!(:kind => "new_comment", :eventable => comment)
    comment.discussion_participants.each do |user|
      unless user == comment.user
        event.notifications.create! :user => user
      end
    end
    event
  end

  def self.new_motion!(motion)
    event = create!(:kind => "new_motion", :eventable => motion)
    motion.group_users.each do |user|
      unless user == motion.author
        event.notifications.create! :user => user
      end
    end
    event
  end

  def self.motion_closed!(motion, closer)
    event = create!(:kind => "motion_closed", :eventable => motion, :user => closer)
    motion.group_users.each do |user|
      event.notifications.create! :user => user
    end
  end

  def self.new_vote!(vote)
    event = create!(:kind => "new_vote", :eventable => vote)
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
    event = create!(:kind => "motion_blocked", :eventable => vote)
    vote.group_users.each do |user|
      unless user == vote.user
        event.notifications.create! :user => user
      end
    end
    event
  end

  def self.membership_requested!(membership)
    event = create!(:kind => "membership_requested", :eventable => membership)
    membership.group_admins.each do |admin|
      event.notifications.create! :user => admin
    end
    event
  end

  def self.user_added_to_group!(membership)
    event = create!(:kind => "user_added_to_group", :eventable => membership)
    event.notifications.create! :user => membership.user
    # Send email only if the user has already accepted invitation to Loomio
    if membership.user.accepted_or_not_invited?
      UserMailer.added_to_group(membership.user, membership.group).deliver
    end
    event
  end

  def self.comment_liked!(comment_vote)
    event = create!(:kind => "comment_liked", :eventable => comment_vote)
    unless comment_vote.user == comment_vote.comment_user
      event.notifications.create! :user => comment_vote.comment_user
    end
    event
  end
end
