class Event < ActiveRecord::Base
  KINDS = %w[new_discussion new_comment new_motion new_vote motion_blocked
             motion_closing_soon motion_closed membership_requested
             user_added_to_group comment_liked user_mentioned]

  has_many :notifications, :dependent => :destroy
  belongs_to :eventable, :polymorphic => true
  belongs_to :user

  validates_inclusion_of :kind, :in => KINDS
  validates_presence_of :eventable

  attr_accessible :kind, :eventable, :user

  def notify!(user)
    notifications.create!(user: user)
  end

  class << self
    def new_discussion!(discussion)
      #soon move this to the notification model

      event = create!(:kind => "new_discussion", :eventable => discussion)

      discussion.group_users_without_discussion_author.each do |user|
        if user.email_notifications_for_group?(discussion.group)
          DiscussionMailer.new_discussion_created(discussion, user).deliver
        end
        event.notify!(user)
      end
    end
    handle_asynchronously :new_discussion!

    def new_comment!(comment)
      event = create!(:kind => "new_comment", :eventable => comment)

      comment.parse_mentions.each do |mentioned_user|
        Event.user_mentioned!(comment, mentioned_user)
      end

      comment.other_discussion_participants.each do |user|
        event.notify!(user)
      end
    end
    handle_asynchronously :new_comment!

    def new_motion!(motion)
      event = create!(:kind => "new_motion", :eventable => motion)

      motion.group_users_without_motion_author.each do |user|
        if user.email_notifications_for_group?(motion.group)
          MotionMailer.new_motion_created(motion, user).deliver
        end
        event.notify!(user)
      end
    end
    handle_asynchronously :new_motion!

    def motion_closed!(motion, closer)
      MotionMailer.motion_closed(motion, motion.author.email).deliver
      event = create!(:kind => "motion_closed", :eventable => motion, :user => closer)
      motion.group_users.each do |user|
        unless user == closer
          event.notifications.create! :user => user
        end
      end
    end

    def motion_closing_soon!(motion)
      event = create!(:kind => "motion_closing_soon", 
                      :eventable => motion)
      motion.group_users.each do |user|
        event.notifications.create!(:user => user)
        if user.subscribed_to_proposal_closure_notifications
          UserMailer.motion_closing_soon(user, motion).deliver!
        end
      end
    end
    handle_asynchronously :motion_closing_soon!

    def new_vote!(vote)
      event = create!(:kind => "new_vote", 
                      :eventable => vote)
      voter = vote.user

      if voter != vote.motion_author
        event.notify!(vote.motion_author)
      end

      if voter != vote.discussion_author
        if vote.motion_author != vote.discussion_author
          event.notify!(vote.discussion_author)
        end
      end
    end
    handle_asynchronously :new_vote!

    def motion_blocked!(vote)
      event = create!(:kind => "motion_blocked", 
                      :eventable => vote)
      vote.other_group_members.each do |user|
        event.notify!(user)
      end
    end
    handle_asynchronously :motion_blocked!

    def membership_requested!(membership)
      event = create!(:kind => "membership_requested", 
                      :eventable => membership)
      membership.group_admins.each do |admin|
        event.notify!(admin)
      end
    end
    handle_asynchronously :membership_requested!

    def user_added_to_group!(membership)
      event = create!(:kind => "user_added_to_group", :eventable => membership)
      event.notify!(membership.user)
      # Send email only if the user has already accepted invitation to Loomio
      if membership.user.accepted_or_not_invited?
        UserMailer.added_to_group(membership).deliver
      end
    end
    handle_asynchronously :user_added_to_group!

    def comment_liked!(comment_vote)
      event = create!(:kind => "comment_liked", :eventable => comment_vote)
      unless comment_vote.user == comment_vote.comment_user
        event.notify!(comment_vote.comment_user)
      end
    end
    handle_asynchronously :comment_liked!

    def user_mentioned!(comment, mentioned_user)
      event = create!(:kind => "user_mentioned", :eventable => comment)
      unless mentioned_user == comment.user
        if mentioned_user.subscribed_to_mention_notifications?
          UserMailer.mentioned(mentioned_user, comment).deliver
        end
        event.notify!(mentioned_user)
      end
    end
    handle_asynchronously :user_mentioned!
  end
end
