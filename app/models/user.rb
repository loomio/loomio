class User < ApplicationRecord
  include CustomCounterCache::Model
  include ReadableUnguessableUrls
  include MessageChannel
  include HasExperiences
  include HasAvatar
  include SelfReferencing
  include NoForbiddenEmails
  include HasMailer
  include CustomCounterCache::Model
  include HasRichText

  is_rich_text    on: :short_bio

  extend HasTokens
  extend HasDefaults

  extend NoSpam
  no_spam_for :name

  has_paper_trail only: [:email_newsletter]

  MAX_AVATAR_IMAGE_SIZE_CONST = 100.megabytes
  BOT_EMAILS = {
    helper_bot: ENV['HELPER_BOT_EMAIL'] || 'contact@loomio.org',
    demo_bot:   ENV['DEMO_BOT_EMAIL'] || 'contact+demo@loomio.org'
  }.freeze

  devise :database_authenticatable, :recoverable, :registerable, :rememberable, :lockable
  attr_accessor :recaptcha
  attr_accessor :restricted
  attr_accessor :token
  attr_accessor :membership_token

  attr_accessor :legal_accepted

  attr_writer   :has_password
  attr_accessor :require_valid_signup
  attr_accessor :require_recaptcha

  before_save :set_legal_accepted_at, if: :legal_accepted

  validates :email, presence: true, email: true, length: {maximum: 200}

  validates :name,               presence: true, if: :require_valid_signup
  validates :legal_accepted,     presence: true, if: :require_legal_accepted
  validate  :validate_recaptcha,                 if: :require_recaptcha

  has_attached_file :uploaded_avatar,
    styles: {
      small:  "#{AVATAR_SIZES[:small]}x#{AVATAR_SIZES[:small]}#",
      medium: "#{AVATAR_SIZES[:medium]}x#{AVATAR_SIZES[:medium]}#",
      large:  "#{AVATAR_SIZES[:large]}x#{AVATAR_SIZES[:large]}#",
    }

  validates_attachment :uploaded_avatar,
    size: { in: 0..MAX_AVATAR_IMAGE_SIZE_CONST.kilobytes },
    content_type: { content_type: /\Aimage/ }

  validates_uniqueness_of :email, conditions: -> { where(email_verified: true) }, if: :email_verified?
  validates_uniqueness_of :username, if: :email_verified
  before_validation :generate_username, if: :email_verified
  validates_length_of :username, maximum: 30
  validates_length_of :short_bio, maximum: 500
  validates_format_of :username, with: /\A[a-z0-9]*\z/, message: I18n.t(:'user.error.username_must_be_alphanumeric')
  validates_confirmation_of :password, if: :password_required?

  validates_length_of :password, minimum: 8, allow_nil: true
  validates :password, nontrivial_password: true, allow_nil: true

  has_many :admin_memberships,
           -> { where('memberships.admin = ?', true) },
           class_name: 'Membership',
           dependent: :destroy

  has_many :memberships,
           -> { where(archived_at: nil) },
           dependent: :destroy

  has_many :archived_memberships,
           -> { where('archived_at IS NOT NULL') },
           class_name: 'Membership'

  has_many :invited_memberships,
           class_name: 'Membership',
           foreign_key: :inviter_id

  has_many :formal_groups,
           -> { where(type: "FormalGroup") },
           through: :memberships,
           class_name: 'FormalGroup',
           source: :group

  has_many :adminable_groups,
           -> { where(archived_at: nil) },
           through: :admin_memberships,
           class_name: 'Group',
           source: :group

  has_many :membership_requests,
           foreign_key: 'requestor_id',
           dependent: :destroy

  has_many :groups,
           -> { where archived_at: nil },
           through: :memberships

  has_many :discussions,
           through: :groups

  has_many :authored_discussions,
           class_name: 'Discussion',
           foreign_key: 'author_id',
           dependent: :destroy

  has_many :polls, foreign_key: :author_id

  has_many :identities, class_name: "Identities::Base", dependent: :destroy

  has_many :reactions, dependent: :destroy
  has_many :stances, foreign_key: :participant_id, dependent: :destroy
  has_many :participated_polls, through: :stances, source: :poll
  has_many :group_polls, through: :groups, source: :polls

  has_many :discussion_readers, dependent: :destroy

  has_many :notifications, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :documents, foreign_key: :author_id, dependent: :destroy
  has_many :drafts, dependent: :destroy
  has_many :login_tokens, dependent: :destroy
  has_many :tags, through: :formal_groups


  has_one :deactivation_response,
          class_name: 'UserDeactivationResponse',
          dependent: :destroy

  before_save :set_avatar_initials
  initialized_with_token :unsubscribe_token,        -> { Devise.friendly_token }
  initialized_with_token :email_api_key,            -> { SecureRandom.hex(16) }
  initialized_with_default :email_on_participation, -> { !ENV['EMAIL_ON_PARTICIPATION_DEFAULT_FALSE'] }


  enum default_membership_volume: [:mute, :quiet, :normal, :loud]

  scope :active, -> { where(deactivated_at: nil) }
  scope :inactive, -> { where("deactivated_at IS NOT NULL") }
  scope :email_catch_up, -> { active.verified.where(email_catch_up: true) }
  scope :sorted_by_name, -> { order("lower(name)") }
  scope :admins, -> { where(is_admin: true) }
  scope :coordinators, -> { joins(:memberships).where('memberships.admin = ?', true).group('users.id') }
  scope :verified, -> { where(email_verified: true) }
  scope :unverified, -> { where(email_verified: false) }
  scope :verified_first, -> { order(email_verified: :desc) }
  scope :search_for, -> (q) { where("users.name ilike :first OR users.name ilike :other OR users.username ilike :first OR users.email ilike :first", first: "#{q}%", other:  "% #{q}%") }
  scope :visible_by, -> (user) { distinct.active.verified.joins(:memberships).where("memberships.group_id": user.group_ids).where.not(id: user.id) }
  scope :mention_search, -> (user, model, query) do
    # allow mentioning of anyone in the organisation
    group_ids = (model.group.parent_or_self.id_and_subgroup_ids + [model.guest_group.id]).compact.uniq
    distinct.active.
      search_for(query).
      joins(:memberships).
      where("memberships.group_id": group_ids).
      where.not('users.id': user.id).
      order("users.name")
  end
  scope :email_when_proposal_closing_soon, -> { active.where(email_when_proposal_closing_soon: true) }

  scope :email_proposal_closing_soon_for, -> (group) {
     email_when_proposal_closing_soon
    .joins(:memberships)
    .where('memberships.group_id': group.id)
  }

  scope :joins_readers, ->(model) {
    joins("LEFT OUTER JOIN discussion_readers dr ON (dr.user_id = users.id AND dr.discussion_id = #{model.discussion_id.to_i})")
  }

  scope :joins_formal_memberships, ->(model) {
     joins("LEFT OUTER JOIN memberships fm ON (fm.user_id = users.id AND fm.group_id = #{model.group_id.to_i})")
    .where('fm.archived_at': nil)
  }

  scope :joins_guest_memberships, ->(model) {
     joins("LEFT OUTER JOIN memberships gm ON (gm.user_id = users.id AND gm.group_id = #{model.guest_group_id.to_i})")
    .where('gm.archived_at': nil)
  }

  # This is a double-nested join select raw sql statement, eek!
  # But, it's not soo complicated. Here's what's going on:
  # Join 1: Grab all instances of a user receiving an announcement from the given model, based on the model's announcement ids
  # Join 2: Group those instances, taking the most recent instance's created_at as the last_notified_at timestamp
  #
  # then, we join that timestamp to the current user query, available in the last_notified_at column
  # scope :with_last_notified_at, ->(model) {
  #   select('users.*, last_notified_at').joins(<<~SQL)
  #     -- join #2
  #     LEFT JOIN (
  #       SELECT users.id as user_id, max(notified.created_at) as last_notified_at
  #       FROM users
  #       -- join #1
  #       LEFT JOIN (
  #         SELECT user_ids, created_at
  #         FROM   announcees
  #         WHERE  announcees.announcement_id IN (#{model.announcement_ids.join(',').presence || '-1'})
  #       ) notified ON notified.user_ids ? users.id::varchar
  #       GROUP BY users.id
  #     ) announcements ON announcements.user_id = users.id
  #   SQL
  # }
  #

  def set_legal_accepted_at
    self.legal_accepted_at = Time.now
  end

  def require_legal_accepted
    self.require_valid_signup && ENV['TERMS_URL']
  end

  def self.email_status_for(email)
    verified_first.find_by(email: email)&.email_status || :unused
  end

  def self.find_for_database_authentication(warden_conditions)
    super(warden_conditions.merge(email_verified: true))
  end

  define_counter_cache(:memberships_count) {|user| user.memberships.formal.count }

  def associate_with_identity(identity)
    if existing = identities.find_by(user: self, uid: identity.uid, identity_type: identity.identity_type)
      existing.update(access_token: identity.access_token)
    else
      identities.push(identity)
      identity.assign_logo! if avatar_kind == 'initials'
    end
    self
  end

  def identity_for(type)
    identities.find_by(identity_type: type)
  end

  def pending_invitation_limit
    ENV.fetch('MAX_PENDING_INVITATIONS', 100).to_i +
    self.invited_memberships.accepted.count        -
    self.invited_memberships.pending.count
  end

  def verified_or_self
    self.class.verified.find_by(email: email) || self
  end

  def first_name
    name.split(' ').first
  end

  def last_name
    name.split(' ').drop(1).join(' ')
  end

  def remember_me
    true
  end

  def is_logged_in?
    true
  end

  def has_password
    self.encrypted_password.present?
  end

  def email_status
    if deactivated_at.present? then :inactive else :active end
  end

  def name_and_email
    "#{name} <#{email}>"
  end

  # Provide can? and cannot? as methods for checking permissions
  def ability
    @ability ||= Ability::Base.new(self)
  end

  delegate :can?, :cannot?, :to => :ability

  def is_member_of?(group)
    !!memberships.find_by(group_id: group&.id)
  end

  def is_admin_of?(group)
    !!memberships.find_by(group_id: group&.id, admin: true)
  end

  def first_name
    self.name.to_s.split(' ').first
  end

  def time_zone
    self[:time_zone] || 'UTC'
  end

  def self.helper_bot
    verified.find_by(email: BOT_EMAILS[:helper_bot]) ||
    create!(email: BOT_EMAILS[:helper_bot],
            name: 'Loomio Helper Bot',
            password: SecureRandom.hex(20),
            email_verified: true,
            avatar_kind: :gravatar)
  end

  def self.demo_bot
    verified.find_by(email: BOT_EMAILS[:helper_bot]) ||
    create!(email: BOT_EMAILS[:demo_bot],
            name: 'Loomio Demo bot',
            email_verified: true,
            avatar_kind: :gravatar)
  end

  def name
    if deactivated_at.present?
      "[deactivated account]"
    else
      self[:name]
    end
  end

  def deactivate!
    return if self.deactivated_at
    former_group_ids = group_ids
    update_attributes(deactivated_at: Time.now, avatar_kind: "initials")
    memberships.update_all(archived_at: Time.now)
    Group.where(id: former_group_ids).map(&:update_memberships_count)
    membership_requests.where("responded_at IS NULL").destroy_all
  end

  def reactivate!
    update_attribute(:deactivated_at, nil)
    archived_memberships.update_all(archived_at: nil)
  end

  # http://stackoverflow.com/questions/5140643/how-to-soft-delete-user-with-devise/8107966#8107966
  def active_for_authentication?
    super && !deactivated_at
  end

  def locale
    selected_locale || detected_locale || I18n.locale
  end

  def update_detected_locale(locale)
    self.update_attribute(:detected_locale, locale) if self.detected_locale&.to_sym != locale.to_sym
  end

  def generate_username
    self.username ||= ::UsernameGenerator.new(self).generate
  end

  def send_devise_notification(notification, *args)
    I18n.with_locale(locale) { devise_mailer.send(notification, self, *args).deliver_now }
  end

  protected

  def password_required?
    !password.nil? || !password_confirmation.nil?
  end

  private

  def validate_recaptcha
    return unless ENV['RECAPTCHA_APP_KEY']
    return if self.persisted?
    return if Clients::Recaptcha.instance.validate(self.recaptcha)
    self.errors.add(:recaptcha, I18n.t(:"user.error.recaptcha"))
  end
end
