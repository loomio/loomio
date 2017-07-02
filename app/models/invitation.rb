class Invitation < ActiveRecord::Base
  extend Null::User

  class InvitationCancelled < StandardError; end
  class InvitationAlreadyUsed < StandardError; end
  class TooManyPending < StandardError; end
  class AllInvitesAreMembers < StandardError; end

  extend FriendlyId
  friendly_id :token
  belongs_to :inviter, class_name: User
  belongs_to :group
  belongs_to :canceller, class_name: User

  update_counter_cache :group, :invitations_count
  update_counter_cache :group, :pending_invitations_count

  validates_presence_of :group, :intent
  validates_inclusion_of :intent, :in => ['start_group', 'join_group', 'join_poll']
  scope :chronologically, -> { order('id asc') }
  before_save :ensure_token_is_present

  delegate :name, to: :inviter, prefix: true, allow_nil: true
  delegate :slack_team_id, to: :group, allow_nil: true
  delegate :identity_type, to: :group, allow_nil: true

  scope :not_cancelled,  -> { where(cancelled_at: nil) }
  scope :pending, -> { not_cancelled.single_use.where(accepted_at: nil) }
  scope :shareable, -> { not_cancelled.where(single_use: false) }
  scope :single_use, -> { not_cancelled.where(single_use: true) }
  scope :ignored, -> (send_count, since) { pending.where(send_count: send_count).where('created_at < ?', since) }

  def locale
    inviter.locale
  end

  def unsubscribe_token
    nil
  end

  def time_zone
    inviter.time_zone
  end

  def email
    recipient_email
  end

  def name
    recipient_name
  end

  def user_from_recipient!
    return unless to_start_group?
    User.find_or_initialize_by(email: self.recipient_email)
        .tap { |user| user.assign_attributes(name: self.recipient_name) }
        .tap(&:save)
  end

  def cancel!(args = {})
    update!(args.slice(:canceller).merge(cancelled_at: DateTime.now))
  end

  def cancelled?
    cancelled_at
  end

  def accepted?
    accepted_at.present?
  end

  def to_start_group?
    intent == 'start_group'
  end

  def to_join_group?
    intent == 'join_group'
  end

  def is_pending?
    !cancelled? && !accepted?
  end

  private
  def ensure_token_is_present
    set_unique_token unless self.token
  end

  def set_unique_token
    begin
      token = SecureRandom.hex.slice(0, 20)
    end while self.class.where(token: token).exists?
    self.token = token
  end

end
