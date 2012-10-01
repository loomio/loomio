class Event < ActiveRecord::Base
  KINDS = %w[new_discussion new_comment new_motion new_vote motion_blocked
             motion_closed motion_outcome membership_requested user_added_to_group comment_liked]

  has_many :notifications, :dependent => :destroy
  belongs_to :eventable, :polymorphic => true
  belongs_to :user

  validates_inclusion_of :kind, :in => KINDS
  validates_presence_of :eventable

  attr_accessible :kind, :eventable, :user

  def self.new_discussion!(discussion)
    group = discussion.group
    event = create!(:kind => "new_discussion", :eventable => discussion)
    discussion.group_users.each do |user|
      if user != discussion.author && user.send_notification?(group, 2) #pending event refactor
        event.notifications.create! :user => user
      end
    end
    event
  end

  def self.new_comment!(comment)
    group = comment.discussion.group
    event = create!(:kind => "new_comment", :eventable => comment)
    comment.discussion.group_users.each do |user|
      if user != comment.user && ((comment.discussion.is_participant?(user) && user.send_notification?(group, 1)) || user.send_notification?(group, 2))
        event.notifications.create! :user => user
      end
    end
    # comment.discussion_participants.each do |user|
    #   if user != comment.user && user.send_notification?(group, 1)
    #     event.notifications.create! :user => user
    #   end
    # end
    event
  end

  def self.new_motion!(motion)
    group = motion.group
    event = create!(:kind => "new_motion", :eventable => motion)
    motion.group_users.each do |user|
      if user != motion.author && user.send_notification?(group, 1)
        event.notifications.create! :user => user
      end
    end
    event
  end

  def self.motion_outcome!(motion, outcome_stater)
    group = motion.group
    event = create!(:kind => "motion_outcome", :eventable => motion, :user => outcome_stater)
    motion.group_users.each do |user|
      if user != outcome_stater && user.send_notification?(group, 1)
        event.notifications.create! :user => user
      end
    end
  end

  def self.motion_closed!(motion, closer)
    group = motion.group
    event = create!(:kind => "motion_closed", :eventable => motion, :user => closer)

    motion.group_users.each do |user| 
      if user != closer && (user.send_notification?(group, 2) || user == motion.author)
        event.notifications.create! :user => user
      end
    end
  end

  def self.new_vote!(vote)
    group = vote.motion.group
    event = create!(:kind => "new_vote", :eventable => vote)
    #pending Craig's notification rewrite - PS
    vote.group_users.each do |user|
      if user != vote.user && user.send_notification?(group, 2) && (user == vote.motion_author || user == vote.discussion_author)
        event.notifications.create! :user => user
      end
    end
    event
  end

  def self.motion_blocked!(vote)
    group = vote.group
    event = create!(:kind => "motion_blocked", :eventable => vote)
    vote.group_users.each do |user| 
      if user != vote.user && (user.send_notification?(group, 1) || user == vote.motion.author)
        event.notifications.create! :user => user
      end
    end
    event
  end

  def self.membership_requested!(membership)
    group = membership.group
    event = create!(:kind => "membership_requested", :eventable => membership)
    membership.group_admins.each do |admin|
      if admin.send_notification?(group, 1)
        event.notifications.create! :user => admin
      end
    end
    event
  end

  def self.user_added_to_group!(membership)
    group = membership.group
    event = create!(:kind => "user_added_to_group", :eventable => membership)
    event.notifications.create! :user => membership.user
    # Send email only if the user has already accepted invitation to Loomio
    if membership.user.accepted_or_not_invited?
      UserMailer.added_to_group(membership.user, membership.group).deliver
    end
    event
  end

  def self.comment_liked!(comment_vote)
    group = comment_vote.comment.discussion.group
    event = create!(:kind => "comment_liked", :eventable => comment_vote)
    unless comment_vote.user == comment_vote.comment_user
      event.notifications.create! :user => comment_vote.comment_user
    end
    event
  end
end
