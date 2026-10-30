class CalendarInvitation < ApplicationRecord
  belongs_to :poll
  belongs_to :user
  has_secure_token
  normalizes :email, with: EmailAddress.method(:normalize)

  validates :email, presence: true

  def available?
    # Deletion hides the thread before its cancellation is delivered. Retain
    # that delivery only for invitees who still belong to the thread.
    user.active? && EmailAddress.normalize(user.email) == email && poll.group.enabled? &&
      (user.can?(:show, poll.topic) || (poll.discarded? && poll.topic.members_include?(user))) &&
      poll.stances.latest.exists?(participant_id: user_id) &&
      (poll.group_id.nil? || poll.topic.members_include?(user))
  end

  def organizer_email
    "calendar+#{token}@#{ENV.fetch('REPLY_HOSTNAME')}"
  end

  def mark_delivered!(sequence:)
    # An older SMTP delivery can complete after a newer one. It must not make
    # replies to the current revision look as though no invitation was sent.
    self.class.where(id: id).where('delivered_sequence IS NULL OR delivered_sequence <= ?', sequence)
      .update_all(delivered_at: Time.current, delivered_sequence: sequence, updated_at: Time.current)
  end
end
