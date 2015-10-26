class Event < ActiveRecord::Base
  KINDS = %w[new_discussion discussion_title_edited discussion_description_edited discussion_edited new_comment
             new_motion new_vote motion_close_date_edited motion_name_edited motion_description_edited motion_edited
             motion_closing_soon motion_closed motion_closed_by_user motion_outcome_created motion_outcome_updated
             membership_requested invitation_accepted user_added_to_group user_joined_group
             membership_request_approved comment_liked comment_replied_to user_mentioned]

  GROUP_KINDS = %w(new_discussion
                   new_motion
                   new_comment
                   new_vote
                   comment_replied_to
                   discussion_title_edited
                   motion_close_date_edited
                   motion_closed
                   motion_closed_by_user
                   motion_name_edited)

  DISCUSSION_KINDS = %w(discussion_description_edited
                        motion_description_edited)

  COMMENT_KINDS = %w(comment_liked)

  has_many :notifications, dependent: :destroy
  belongs_to :eventable, polymorphic: true
  belongs_to :discussion
  belongs_to :user

  scope :sequenced, -> { where('sequence_id is not null').order('sequence_id asc') }
  scope :chronologically, -> { order('created_at asc') }

  after_create :call_thread_item_created
  after_destroy :call_thread_item_destroyed

  after_create :publish_message
  after_create :notify_webhooks!, if: :discussion

  validates_inclusion_of :kind, :in => KINDS
  validates_presence_of :eventable

  acts_as_sequenced scope: :discussion_id, column: :sequence_id, skip: lambda {|e| e.discussion.nil? || e.discussion_id.nil? }



  def notify!(user)
    notifications.create!(user: user)
  end

  def belongs_to?(this_user)
    self.user_id == this_user.id
  end

  def publish_message
    MessageChannelService.publish(EventSerializer.new(self).as_json, to: channel_object)
  end

  def notify_webhooks!
    group = self.discussion.group
    self.discussion.webhooks.each { |webhook| WebhookService.publish! webhook: webhook, event: self }
    group.webhooks.each           { |webhook| WebhookService.publish! webhook: webhook, event: self }
    group.parent.webhooks.each    { |webhook| WebhookService.publish! webhook: webhook, event: self } if group.is_subgroup? && group.is_visible_to_parent_members
  end
  handle_asynchronously :notify_webhooks!

  private

  def channel_object
    if    GROUP_KINDS.include?      self.kind then self.eventable.group
    elsif DISCUSSION_KINDS.include? self.kind then self.eventable
    elsif COMMENT_KINDS.include?    self.kind then self.eventable.comment.discussion
    end
  end

  def call_thread_item_created
    discussion.thread_item_created!(self) if discussion_id.present?
  end

  def call_thread_item_destroyed
    discussion.thread_item_destroyed!(self) if discussion_id.present?
  end
end
