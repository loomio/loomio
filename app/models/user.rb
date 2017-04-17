class User < ActiveRecord::Base
  include AvatarInitials
  include ReadableUnguessableUrls
  include MessageChannel
  include HasExperiences
  include HasAvatar
  include UsesWithoutScope

  MAX_AVATAR_IMAGE_SIZE_CONST = 100.megabytes

  devise :database_authenticatable, :recoverable, :registerable, :rememberable, :trackable, :omniauthable, :validatable
  attr_accessor :honeypot
  attr_accessor :restricted

  validates :email, presence: true, uniqueness: true, email: true
  #validates :name, presence: true
  validates_inclusion_of :uses_markdown, in: [true,false]

  has_many :stances, as: :participant

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
  validates_format_of :username, with: /\A[a-z0-9]*\z/, message: I18n.t(:'error.username_must_be_alphanumeric')

  validates_length_of :password, minimum: 8, allow_nil: true
  validates :password, nontrivial_password: true, allow_nil: true

  has_many :contacts, dependent: :destroy
  has_many :admin_memberships,
           -> { where('memberships.admin = ? AND memberships.is_suspended = ?', true, false) },
           class_name: 'Membership',
           dependent: :destroy

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

  has_many :motions,
           through: :discussions

  has_many :authored_motions,
           class_name: 'Motion',
           foreign_key: 'author_id',
           dependent: :destroy

  has_many :polls, foreign_key: :author_id
  has_many :communities, through: :polls, class_name: "Communities::Base"
  has_many :visitors, through: :communities

  has_many :votes, dependent: :destroy
  has_many :comment_votes, dependent: :destroy
  has_many :stances, as: :participant, dependent: :destroy
  has_many :participated_polls, through: :stances, source: :poll

  has_many :discussion_readers, dependent: :destroy
  has_many :omniauth_identities, dependent: :destroy

  has_many :notifications, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :attachments, dependent: :destroy
  has_many :drafts, dependent: :destroy

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

  # move to ThreadMailerQuery
  scope :email_when_proposal_closing_soon, -> { active.where(email_when_proposal_closing_soon: true) }

  scope :email_proposal_closing_soon_for, -> (group) {
    active.
    joins(:memberships).
    where('memberships.group_id = ?', group.id).
    where('users.email_when_proposal_closing_soon = ?', true)
  }

  def user_id
    id
  end

  def participation_token
    nil
  end

  def is_logged_in?
    true
  end

  def first_name
    name.split(' ').first
  end

  def name_and_email
    "#{name} <#{email}>"
  end

  # Provide can? and cannot? as methods for checking permissions
  def ability
    @ability ||= Ability.new(self)
  end

  delegate :can?, :cannot?, :to => :ability

  def is_group_admin?(group=nil)
    if group.present?
      admin_memberships.where(group_id: group.id).any?
    else
      admin_memberships.any?
    end
  end

  def is_member_of?(group)
    !!memberships.find_by(group_id: group&.id)
  end

  def is_admin_of?(group)
    !!memberships.find_by(group_id: group&.id, admin: true)
  end

  def time_zone_city
    TimeZoneToCity.convert time_zone
  end

  def time_zone
    self[:time_zone] || 'UTC'
  end

  def group_membership(group)
    memberships.for_group(group).first
  end

  def self.find_by_email(email)
    User.where('lower(email) = ?', email.to_s.downcase).first
  end

  def self.helper_bot
    find_by(email: helper_bot_email) ||
    create!(email: helper_bot_email,
            name: 'Loomio Helper Bot',
            password: SecureRandom.hex(20),
            uses_markdown: true,
            avatar_kind: :gravatar)
  end

  def self.helper_bot_email
    ENV['HELPER_BOT_EMAIL'] || 'contact@loomio.org'
  end

  def subgroups
    groups.where("parent_id IS NOT NULL")
  end

  def parent_groups
    groups.where("parent_id IS NULL").order("LOWER(name)")
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
    selected_locale || detected_locale || I18n.default_locale
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
