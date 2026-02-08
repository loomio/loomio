class User < ApplicationRecord
  include CustomCounterCache::Model
  include ReadableUnguessableUrls
  include MessageChannel
  include HasExperiences
  include HasAvatar
  include SelfReferencing
  include NoForbiddenEmails
  include CustomCounterCache::Model
  include HasRichText
  include LocalesHelper

  is_rich_text on: :short_bio

  extend HasTokens
  extend HasDefaults

  extend NoSpam
  no_spam_for :name, :email

  has_paper_trail only: [:name, :username, :email, :email_newsletter, :deactivated_at, :deactivator_id]

  MAX_AVATAR_IMAGE_SIZE_CONST = 100.megabytes

  devise :database_authenticatable, :recoverable, :registerable, :rememberable, :lockable, :trackable
  devise :pwned_password if Rails.env.production?
  attr_accessor :restricted
  attr_accessor :token
  attr_accessor :membership_token
  attr_accessor :group_token
  attr_accessor :discussion_reader_token
  attr_accessor :stance_token

  attr_accessor :legal_accepted

  attr_writer   :has_password
  attr_accessor :require_valid_signup

  before_save :set_legal_accepted_at, if: :legal_accepted

  validates :email, presence: true, email: true, length: { maximum: 200 }

  validates :name,               presence: true, if: :require_valid_signup
  validates :legal_accepted,     presence: true, if: :require_legal_accepted

  has_one_attached :uploaded_avatar

  validates_uniqueness_of :email
  validates_uniqueness_of :username, if: :email
  before_validation :generate_username, if: :email
  validates_length_of :name, maximum: 100
  validates_length_of :username, maximum: 30
  validates_length_of :short_bio, maximum: 5000
  validates_format_of :username, with: /\A[a-z0-9]*\z/, message: I18n.t(:'user.error.username_must_be_alphanumeric')
  validates_confirmation_of :password, if: :password_required?

  validates_length_of :password, minimum: 8, allow_nil: true

  has_many :admin_memberships,
           -> { where('memberships.admin': true, revoked_at: nil) },
           class_name: 'Membership'

  has_many :memberships, -> { active }, dependent: :destroy
  has_many :all_memberships, dependent: :destroy, class_name: "Membership"

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

  has_many :identities, class_name: "Identity", dependent: :destroy

  has_many :reactions, dependent: :destroy
  has_many :stances, foreign_key: :participant_id, dependent: :destroy
  has_many :participated_polls, through: :stances, source: :poll
  has_many :group_polls, through: :groups, source: :polls

  has_many :discussion_readers, dependent: :destroy
  has_many :guest_discussion_readers, -> { DiscussionReader.active.guests }, class_name: 'DiscussionReader', dependent: :destroy
  has_many :guest_discussions, through: :guest_discussion_readers, source: :discussion
  has_many :guest_stances, -> { Stance.latest.guests }, class_name: 'Stance', dependent: :destroy, foreign_key: :participant_id
  has_many :guest_polls, through: :guest_stances, source: :poll
  has_many :notifications, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :documents, foreign_key: :author_id, dependent: :destroy
  has_many :login_tokens, dependent: :destroy
  has_many :events, dependent: :destroy

  has_many :tags, through: :groups

  before_save :set_avatar_initials

  initialized_with_token :unsubscribe_token
  initialized_with_token :email_api_key
  initialized_with_token :api_key
  initialized_with_token :secret_token

  enum :default_membership_volume, [:mute, :quiet, :normal, :loud]

  scope :active, -> { where(deactivated_at: nil) }
  scope :no_spam_complaints, -> { where(complaints_count: 0) }
  scope :has_spam_complaints, -> { where("complaints_count > 0") }
  scope :deactivated, -> { where("deactivated_at IS NOT NULL") }
  scope :sorted_by_name, -> { order("lower(name)") }
  scope :admins, -> { where(is_admin: true) }
  scope :coordinators, -> { joins(:memberships).where('memberships.admin = ?', true).group('users.id') }
  scope :verified, -> { where(email_verified: true) }
  scope :unverified, -> { where(email_verified: false) }
  scope :search_for, lambda { |q|
    where("users.name ilike :first OR
           users.name ilike :other OR
           users.username ilike :first OR
           users.email ilike :first",
          first: "#{q}%", other: "% #{q}%")
  }
  scope :visible_by, ->(user) { distinct.active.verified.joins(:memberships).where("memberships.group_id": user.group_ids).where.not(id: user.id) }
  scope :humans, -> { where(bot: false) }
  scope :bots, -> { where(bot: true) }

  scope :mention_search, lambda { |model, query|
    return none unless model.present?

    ids = []
    if model.is_a?(User)
      return active.search_for(query).where(id: User.visible_by(model).pluck(:id))
    end

    if model.group_id
      ids += Membership.active.where(group_id: model.group_id).pluck(:user_id) if model.group_id
    end

    if model.discussion_id
      ids += DiscussionReader.active.guests.where(discussion_id: model.discussion_id).pluck(:user_id)
    end

    if model.poll_id
      ids += Stance.latest.guests.where(poll_id: model.poll_id).pluck(:participant_id)
    end

    if model.respond_to?(:poll_ids) and model.poll_ids.any?
      ids += Stance.latest.guests.where(poll_id: model.poll_ids).pluck(:participant_id)
    end

    active.search_for(query).where(id: ids)
  }

  scope :email_when_proposal_closing_soon, -> { active.where(email_when_proposal_closing_soon: true) }

  scope :email_proposal_closing_soon_for, -> (group) {
     email_when_proposal_closing_soon
    .joins(:memberships)
    .where('memberships.group_id': group.id)
  }

  def default_format
    if experiences['html-editor.uses-markdown']
      'md'
    else
      'html'
    end
  end

  def date_time_pref
    self[:date_time_pref] || 'day_abbr'
  end

  def author
    self
  end

  def is_paying?
    group_ids = self.group_ids.concat(self.groups.pluck(:parent_id).compact).uniq
    Group.where(id: group_ids).where(parent_id: nil).joins(:subscription).where.not('subscriptions.plan': 'trial').exists?
  end

  def is_paying
    is_paying?
  end

  def invitations_rate_limit
    if user.is_paying?
      ENV.fetch('PAID_INVITATIONS_RATE_LIMIT', 50000)
    else
      ENV.fetch('TRIAL_INVITATIONS_RATE_LIMIT', 500)
    end.to_i
  end

  def browseable_group_ids
    Group.where(
      "id in (:group_ids) OR
      (parent_id in (:group_ids) AND is_visible_to_parent_members = TRUE)",
      group_ids: self.group_ids).pluck(:id)
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
    "\"#{name}\" <#{email}>"
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
    return 'UTC' if self[:time_zone] == "Etc/Unknown"
    self[:time_zone] || 'UTC'
  end

  def self.helper_bot
    verified.find_by(email: ApplicationMailer::NOTIFICATIONS_EMAIL_ADDRESS) ||
    create!(email: ApplicationMailer::NOTIFICATIONS_EMAIL_ADDRESS,
            name: 'Loomio Helper Bot',
            password: SecureRandom.hex(20),
            email_verified: true,
            bot: true,
            avatar_kind: :gravatar)
  end

  def name
    if deactivated_at && self[:name].nil?
      I18n.t('profile_page.deleted_account')
    else
      self[:name]
    end
  end

  def name_or_username
    self[:name] || self[:username]
  end

  # http://stackoverflow.com/questions/5140643/how-to-soft-delete-user-with-devise/8107966#8107966
  def active_for_authentication?
    super && !deactivated_at
  end

  def locale
    first_supported_locale([selected_locale, detected_locale].compact).to_s
  end

  def update_detected_locale(locale)
    self.update_attribute(:detected_locale, locale) if detected_locale&.to_s != locale.to_s
  end

  def generate_username
    self.username ||= ::UsernameGenerator.new(self).generate
  end

  def send_devise_notification(notification, *args)
    I18n.with_locale(locale) { devise_mailer.send(notification, self, *args).deliver_now }
  end

  def self.ransackable_attributes(auth_object = nil)
    [
    "avatar_initials",
    "avatar_kind",
    "city",
    "content_locale",
    "country",
    "complaints_count",
    "created_at",
    "current_sign_in_at",
    "current_sign_in_ip",
    "date_time_pref",
    "deactivated_at",
    "detected_locale",
    "email",
    "email_catch_up",
    "email_catch_up_day",
    "email_newsletter",
    "email_on_participation",
    "email_verified",
    "email_when_mentioned",
    "email_when_proposal_closing_soon",
    "id",
    "is_admin",
    "key",
    "last_seen_at",
    "last_sign_in_at",
    "last_sign_in_ip",
    "legal_accepted_at",
    "link_previews",
    "location",
    "locked_at",
    "memberships_count",
    "name",
    "region",
    "secret_token",
    "selected_locale",
    "short_bio",
    "short_bio_format",
    "sign_in_count",
    "time_zone",
    "updated_at",
    "uploaded_avatar_content_type",
    "uploaded_avatar_file_name",
    "uploaded_avatar_file_size",
    "uploaded_avatar_updated_at",
    "username"]
  end

  protected

  def password_required?
    !password.nil? || !password_confirmation.nil?
  end
end
