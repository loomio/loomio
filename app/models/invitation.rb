class Invitation < ActiveRecord::Base
  include Null::User

  class InvitationCancelled < StandardError; end
  class TooManyPending < StandardError; end
  class TooManyCancelled < StandardError; end
  class AllInvitesAreMembers < StandardError; end
  class InvitationAlreadyUsed < StandardError
    attr_accessor :invitation
    def initialize(invitation)
      @invitation = invitation
      super
    end
  end

  include UsesOrganisationScope

  extend FriendlyId
  friendly_id :token
  belongs_to :inviter, class_name: User
  belongs_to :group
  belongs_to :canceller, class_name: User

  update_counter_cache :group, :invitations_count
  update_counter_cache :group, :pending_invitations_count

  validates_presence_of :group, :intent
  validates_inclusion_of :intent, :in => ['start_group', 'join_group', 'join_poll']
  validates_exclusion_of :recipient_email, in: User::FORBIDDEN_EMAIL_ADDRESSES
  scope :chronologically, -> { order('id asc') }
  before_save :ensure_token_is_present
  after_initialize :apply_null_methods!

  delegate :name, to: :inviter, prefix: true, allow_nil: true

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

  def unsubscribe_token
    token
  end

  def mailer
    case intent
    when 'join_group' then GroupMailer
    when 'join_poll' then PollMailer
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
