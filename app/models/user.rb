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
  include LocalesHelper

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

  devise :database_authenticatable, :recoverable, :registerable, :rememberable, :lockable, :trackable
  attr_accessor :recaptcha
  attr_accessor :restricted
  attr_accessor :token
  attr_accessor :membership_token
  attr_accessor :group_token
  attr_accessor :discussion_reader_token
  attr_accessor :stance_token

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
  validates_length_of :short_bio, maximum: 5000
  validates_format_of :username, with: /\A[a-z0-9]*\z/, message: I18n.t(:'user.error.username_must_be_alphanumeric')
  validates_confirmation_of :password, if: :password_required?

  validates_length_of :password, minimum: 8, allow_nil: true
  validates :password, nontrivial_password: true, allow_nil: true

  has_many :admin_memberships,
           -> { where('memberships.admin = ?', true) },
           class_name: 'Membership'

  has_many :memberships, -> { where(archived_at: nil) }, dependent: :destroy

  has_many :archived_memberships,
           -> { where('archived_at IS NOT NULL') },
           class_name: 'Membership'

  has_many :invited_memberships,
           class_name: 'Membership',
           foreign_key: :inviter_id

  has_many :groups,
           through: :memberships,
           class_name: 'Group',
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

  has_many :discussions, through: :groups

  has_many :authored_discussions, class_name: 'Discussion', foreign_key: 'author_id', dependent: :destroy
  has_many :authored_polls, class_name: 'Poll', foreign_key: :author_id, dependent: :destroy
  has_many :created_groups, class_name: 'Group', foreign_key: :creator_id, dependent: :destroy

  has_many :identities, class_name: "Identities::Base", dependent: :destroy

  has_many :reactions, dependent: :destroy
  has_many :stances, foreign_key: :participant_id, dependent: :destroy
  has_many :participated_polls, through: :stances, source: :poll
  has_many :group_polls, through: :groups, source: :polls

  has_many :discussion_readers, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :documents, foreign_key: :author_id, dependent: :destroy
  has_many :login_tokens, dependent: :destroy
  has_many :events, dependent: :destroy

  has_many :tags, through: :groups

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
    # allow mentioning of anyone in the organisation or guests of the discussion
    group_ids = model.group.parent_or_self.id_and_subgroup_ids
    relation = active.search_for(query).
                      joins("LEFT OUTER JOIN memberships ON memberships.user_id = users.id").
                      where.not('users.id': user.id).order("users.name")
    if model.discussion_id
      relation.joins("LEFT OUTER JOIN discussion_readers dr ON dr.user_id = users.id AND dr.discussion_id = #{model.discussion_id}").
               where("memberships.group_id IN (:group_ids) OR dr.id IS NOT NULL", group_ids: group_ids)
    else
      relation.where("memberships.group_id IN (:group_ids)", group_ids: group_ids)
    end
  end
  scope :email_when_proposal_closing_soon, -> { active.where(email_when_proposal_closing_soon: true) }

  scope :email_proposal_closing_soon_for, -> (group) {
     email_when_proposal_closing_soon
    .joins(:memberships)
    .where('memberships.group_id': group.id)
  }

  scope :joins_discussion_readers, ->(model) {
    joins("LEFT OUTER JOIN discussion_readers dr ON (dr.user_id = users.id AND dr.discussion_id = #{model.discussion_id.to_i})")
  }

  scope :joins_memberships, ->(model) {
     joins("LEFT OUTER JOIN memberships fm ON (fm.user_id = users.id AND fm.group_id = #{model.group_id.to_i})")
    .where('fm.archived_at': nil)
  }

  def default_format
    if experiences['html-editor.uses-markdown']
      'md'
    else
      'html'
    end
  end

  def set_legal_accepted_at
    self.legal_accepted_at = Time.now
  end

  def require_legal_accepted
    self.require_valid_signup && ENV['TERMS_URL']
  end

  def self.email_status_for(email)
    find_by(email: email)&.email_status || :unused
  end

  def self.find_for_database_authentication(warden_conditions)
    super(warden_conditions.merge(email_verified: true))
  end

  define_counter_cache(:memberships_count) {|user| user.memberships.count }

  def associate_with_identity(identity)
    if existing = identities.find_by(user: self, uid: identity.uid, identity_type: identity.identity_type)
      existing.update(access_token: identity.access_token)
      identity = existing
    else
      identities.push(identity)
    end

    update(name: identity.name) if self.name.nil?
    identity.assign_logo! if self.avatar_url.nil?
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
    @ability ||= ::Ability::Base.new(self)
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


  # http://stackoverflow.com/questions/5140643/how-to-soft-delete-user-with-devise/8107966#8107966
  def active_for_authentication?
    super && !deactivated_at
  end

  def locale
    first_supported_locale([selected_locale, detected_locale].compact)
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
