class Invitation < ApplicationRecord
  include CustomCounterCache::Model
  include Null::User
  include AvatarInitials

  class AllInvitesAreMembers < StandardError; end

  include UsesOrganisationScope

  extend FriendlyId
  friendly_id :token
  belongs_to :inviter, class_name: 'User'
  belongs_to :group
  belongs_to :canceller, class_name: 'User'

  has_many :announcees, dependent: :destroy, as: :announceable

  update_counter_cache :group, :invitations_count
  update_counter_cache :group, :pending_invitations_count

  validates_presence_of :group, :intent
  validates_inclusion_of :intent, in: ['join_group', 'join_discussion', 'join_poll', 'join_outcome']
  validates_exclusion_of :recipient_email, in: User::FORBIDDEN_EMAIL_ADDRESSES
  scope :chronologically, -> { order('id asc') }
  before_save :ensure_token_is_present
  after_initialize :apply_null_methods!

  delegate :name, to: :inviter, prefix: true, allow_nil: true
  delegate :body, to: :discussion, allow_nil: true
  delegate :documents, to: :discussion, allow_nil: true

  scope :not_cancelled,  -> { where(cancelled_at: nil) }
  scope :cancelled, -> { where.not(cancelled_at: nil) }
  scope :useable, -> { not_cancelled.where(accepted_at: nil) }
  scope :pending, -> { useable.single_use }
  scope :shareable, -> { not_cancelled.where(single_use: false) }
  scope :single_use, -> { not_cancelled.where(single_use: true) }
  scope :ignored, -> (send_count, since) { pending.where(send_count: send_count).where('created_at < ?', since) }
  scope :to_verified_user, -> { pending.joins("INNER JOIN users ON users.email_verified IS TRUE AND users.email = invitations.recipient_email") }
  scope :to_unverified_user, -> { pending.joins("INNER JOIN users ON users.email_verified IS FALSE AND users.email = invitations.recipient_email") }
  scope :to_unrecognized_user, -> { pending.joins("LEFT OUTER JOIN users ON users.email = invitations.recipient_email").where("users.id IS NULL") }

  scope :with_last_notified_at, -> {
    select('invitations.*, last_notified_at').joins(<<~SQL)
      LEFT JOIN (
        SELECT events.eventable_id, max(events.created_at) as last_notified_at
        FROM events
        WHERE events.eventable_type = 'Invitation'
        GROUP BY events.eventable_id
      ) e ON e.eventable_id = "invitations"."id"
    SQL
  }

  def poll
    target_model if [:join_poll, :join_outcome].include? intent.to_sym
  end

  def discussion
    target_model if intent.to_sym == :join_discussion
  end

  def unsubscribe_token
    token
  end

  def message_channel
    "invitation-#{token}"
  end

  def mailer
    case intent.to_sym
    when :join_group               then GroupMailer
    when :join_discussion          then DiscussionMailer
    when :join_poll, :join_outcome then PollMailer
    end
  end

  def locale
    (inviter || group.creator || I18n).locale
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
