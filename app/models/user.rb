class User < ActiveRecord::Base
  include ReadableUnguessableUrls
  include MessageChannel
  include HasExperiences
  include HasAvatar
  include UsesWithoutScope
  include SelfReferencing
  include NoForbiddenEmails

  MAX_AVATAR_IMAGE_SIZE_CONST = 100.megabytes
  BOT_EMAILS = {
    helper_bot: ENV['HELPER_BOT_EMAIL'] || 'contact@loomio.org',
    demo_bot:   ENV['DEMO_BOT_EMAIL'] || 'contact+demo@loomio.org'
  }.freeze

  devise :database_authenticatable, :recoverable, :registerable, :rememberable, :trackable
  attr_accessor :recaptcha
  attr_accessor :restricted
  attr_accessor :token
  attr_writer :has_password

  validates :email, presence: true, email: true, length: {maximum: 200}

  has_attached_file :uploaded_avatar,
    styles: {
      small:  "#{AVATAR_SIZES[:small]}x#{AVATAR_SIZES[:small]}#",
      medium: "#{AVATAR_SIZES[:medium]}x#{AVATAR_SIZES[:medium]}#",
      large:  "#{AVATAR_SIZES[:large]}x#{AVATAR_SIZES[:large]}#",
    }

  validates_attachment :uploaded_avatar,
    size: { in: 0..MAX_AVATAR_IMAGE_SIZE_CONST.kilobytes },
    content_type: { content_type: /\Aimage/ },
    file_name: { matches: [/png\Z/i, /jpe?g\Z/i, /gif\Z/i] }

  validates_uniqueness_of :username
  validates_length_of :username, maximum: 30
  validates_length_of :short_bio, maximum: 500
  validates_format_of :username, with: /\A[a-z0-9]*\z/, message: I18n.t(:'user.error.username_must_be_alphanumeric')
  validates_confirmation_of :password, if: :password_required?

  validates_length_of :password, minimum: 8, allow_nil: true
  validates :password, nontrivial_password: true, allow_nil: true
  validate  :ensure_recaptcha, if: :recaptcha

  has_many :contacts, dependent: :destroy
  has_many :admin_memberships,
           -> { where('memberships.admin = ? AND memberships.is_suspended = ?', true, false) },
           class_name: 'Membership',
           dependent: :destroy

  has_many :formal_groups,
           -> { where(type: "FormalGroup") },
           through: :memberships,
           class_name: 'FormalGroup',
           source: :group

  has_many :adminable_groups,
           -> { where( archived_at: nil) },
           through: :admin_memberships,
           class_name: 'Group',
           source: :group

  has_many :memberships,
           -> { where(is_suspended: false, archived_at: nil) },
           dependent: :destroy

  has_many :archived_memberships,
           -> { where('archived_at IS NOT NULL') },
           class_name: 'Membership'

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
  has_many :attachments, dependent: :destroy
  has_many :drafts, dependent: :destroy
  has_many :login_tokens, dependent: :destroy

  has_one :deactivation_response,
          class_name: 'UserDeactivationResponse',
          dependent: :destroy

  before_validation :generate_username
  before_save :set_avatar_initials,
              :ensure_unsubscribe_token,
              :ensure_email_api_key

  enum default_membership_volume: [:mute, :quiet, :normal, :loud]

  scope :active, -> { where(deactivated_at: nil) }
  scope :inactive, -> { where("deactivated_at IS NOT NULL") }
  scope :email_missed_yesterday, -> { active.where(email_missed_yesterday: true) }
  scope :sorted_by_name, -> { order("lower(name)") }
  scope :admins, -> { where(is_admin: true) }
  scope :coordinators, -> { joins(:memberships).where('memberships.admin = ?', true).group('users.id') }
  scope :mentioned_in, ->(model) { where(id: model.notifications.user_mentions.pluck(:user_id)) }
  scope :verified, -> { where(email_verified: true) }
  scope :unverified, -> { where(email_verified: false) }
  scope :verified_first, -> { order(email_verified: :desc) }

  # move to ThreadMailerQuery
  scope :email_when_proposal_closing_soon, -> { active.where(email_when_proposal_closing_soon: true) }

  scope :email_proposal_closing_soon_for, -> (group) {
     email_when_proposal_closing_soon
    .joins(:memberships)
    .where('memberships.group_id': group.id)
  }

  def self.email_status_for(email)
    (verified_first.find_by(email: email) || LoggedOutUser.new).email_status
  end

  define_counter_cache(:memberships_count) {|user| user.memberships.formal.count }

  def associate_with_identity(identity)
    if existing = identities.find_by(user: self, uid: identity.uid, identity_type: identity.identity_type)
      existing.update(access_token: identity.access_token)
    else
      identities.push(identity)
      identity.assign_logo! if avatar_kind == 'initials'
    end
  end

  def identity_for(type)
    identities.find_by(identity_type: type)
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
    @ability ||= Ability.new(self)
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

  def ensure_email_api_key
    self.email_api_key ||= SecureRandom.hex(16)
  end

  def ensure_recaptcha
    return if Clients::Recaptcha.instance.validate(self.recaptcha)
    self.errors.add(:recaptcha, I18n.t(:"user.error.recaptcha"))
  end

  def ensure_unsubscribe_token
    if unsubscribe_token.blank?
      found = false
      while not found
        token = Devise.friendly_token
        found = true unless self.class.where(:unsubscribe_token => token).exists?
      end
      self.unsubscribe_token = token
    end
  end
end
