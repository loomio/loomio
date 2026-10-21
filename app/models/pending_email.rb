# A message awaiting a group coordinator's sender approval. Message content and
# attachments stay in Action Mailbox while this queue record exists.
class PendingEmail < ApplicationRecord
  include HasNotifications

  belongs_to :group
  belongs_to :inbound_email, class_name: 'ActionMailbox::InboundEmail'
  enum :status, {pending: 0, blocked: 1}
  before_validation :record_envelope, on: :create
  attr_readonly :inbound_email_id, :group_id, :sender_email, :sender_name, :subject

  def message
    @message ||= InboundEmailMessage.new(inbound_email)
  end

  # Keep the existing approval API: completed actions disappear from its list.
  def released
    destroyed? || blocked?
  end

  def title
    address = Mail::Address.new(sender_email)
    address.display_name = sender_name
    address.format
  end

  def title_model
    group
  end

  private

  # The approval list needs envelope metadata, never a raw-message download.
  def record_envelope
    self.sender_email = message.sender_email
    self.sender_name = message.sender_name
    self.subject = message.subject
  end
end
