class User < ActiveRecord::Base
  include AvatarInitials
  include ReadableUnguessableUrls

  require 'net/http'
  require 'digest/md5'

  AVATAR_KINDS = %w[initials uploaded gravatar]
  IMAGE_SIZES = {
    large: 170,
    medlarge: 70,
    medium: 35,
    small: 25
  }.with_indifferent_access.freeze
  MAX_AVATAR_IMAGE_SIZE_CONST = 10.megabytes

  devise :database_authenticatable, :recoverable, :registerable, :rememberable, :trackable, :omniauthable
  attr_accessor :honeypot

  validates :email, presence: true, uniqueness: true, email: true
  validates_inclusion_of :uses_markdown, in: [true,false]

  has_attached_file :uploaded_avatar,
    styles: {
              large:    "#{IMAGE_SIZES[:large]}x#{IMAGE_SIZES[:large]}",
              medlarge: "#{IMAGE_SIZES[:medlarge]}x#{IMAGE_SIZES[:medlarge]}",
              medium:   "#{IMAGE_SIZES[:medium]}x#{IMAGE_SIZES[:medium]}",
              small:    "#{IMAGE_SIZES[:small]}x#{IMAGE_SIZES[:small]}"
            },
    default_url: "/avatars/:style/missing.png"
  validates_attachment :uploaded_avatar,
    size: { in: 0..User::MAX_AVATAR_IMAGE_SIZE_CONST.kilobytes },
    content_type: { content_type: /\Aimage/ },
    file_name: { matches: [/png\Z/i, /jpe?g\Z/i, /gif\Z/i] }

  validates_inclusion_of :avatar_kind, in: AVATAR_KINDS

  validates_uniqueness_of :username, allow_blank: true
  validates_length_of :username, maximum: 30, allow_blank: true

  validates_length_of :password, minimum: 8, :allow_nil => true
  validates :password, nontrivial_password: true, :allow_nil => true

  include Gravtastic
  gravtastic  :rating => 'pg',
              :default => 'none'


  has_many :contacts
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
           foreign_key: 'requestor_id'

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

  has_many :votes, dependent: :destroy
  has_many :comment_votes, dependent: :destroy

  has_many :discussion_readers, dependent: :destroy
  has_many :motion_readers, dependent: :destroy
  has_many :omniauth_identities, dependent: :destroy


  has_many :notifications, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :attachments

  has_one :deactivation_response,
          class_name: 'UserDeactivationResponse'

  before_save :set_avatar_initials,
              :ensure_unsubscribe_token,
              :ensure_email_api_key,
              :generate_username

  before_create :set_default_avatar_kind

  scope :active, -> { where(deactivated_at: nil) }
  scope :inactive, -> { where("deactivated_at IS NOT NULL") }
  scope :email_missed_yesterday, -> { active.where(email_missed_yesterday: true) }
  scope :sorted_by_name, -> { order("lower(name)") }
  scope :admins, -> { where(is_admin: true) }
  scope :coordinators, -> { joins(:memberships).where('memberships.admin = ?', true).group('users.id') }

  # move to ThreadMailerQuery
  scope :email_when_proposal_closing_soon, -> { active.where(email_when_proposal_closing_soon: true) }

  scope :email_proposal_closing_soon_for, -> (group) {
    active.
    joins(:memberships).
    where('memberships.group_id = ?', group.id).
    where('users.email_when_proposal_closing_soon = ?', true)
  }

  scope :without, -> (users) {
    users = Array(users).compact

    if users.size > 0
      where('users.id NOT IN (?)', users)
    else
      all
    end
  }

  def self.email_taken?(email)
    User.find_by_email(email).present?
  end

  def user_id
    id
  end

  def is_logged_in?
    true
  end

  def is_logged_out?
    !is_logged_in?
  end

  def cached_group_ids
    @cached_group_ids ||= group_ids
  end

  def top_level_groups
    parents = groups.parents_only.order(:name).includes(:children)
    orphans = groups.where('parent_id not in (?)', parents.map(&:id))
    (parents.to_a + orphans.to_a).sort{|a, b| a.full_name <=> b.full_name }
  end

  def inbox_groups
    groups.where('memberships.inbox_position is not null').order('memberships.inbox_position')
  end

  def groups_discussions_can_be_started_in
    (groups.where(members_can_start_discussions: true) | adminable_groups).
     sort{|a,b| a.full_name <=> b.full_name}
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

  def voting_motions
    motions.voting
  end

  def closed_motions
    motions.closed
  end

  def is_group_admin?(group=nil)
    if group.present?
      admin_memberships.where(group_id: group.id).any?
    else
      admin_memberships.any?
    end
  end

  def is_member_of?(group)
    memberships.where(group_id: group.id).any?
  end

  def time_zone_city
    TimeZoneToCity.convert time_zone
  end

  def time_zone
    self[:time_zone] || 'UTC'
  end

  def is_parent_group_member?(group)
    memberships.for_group(group.parent).exists? if group.parent
  end

  def group_membership(group)
    memberships.for_group(group).first
  end

  def unviewed_notifications
    notifications.unviewed
  end

  def mark_notifications_as_viewed!(latest_viewed_id)
    notifications.where('id <= ?', latest_viewed_id).
      update_all(:viewed_at => Time.now)
  end

  def self.loomio_helper_bot(password: nil)
    where(email: 'contact@loom.io').first ||
    create!(email: 'contact@loom.io', name: 'Loomio Helper Bot', password: password || SecureRandom.hex)
  end

  def self.helper_bots
    where(email: ['contact@loomio.org', 'contact@loom.io'])
  end

  def self.find_by_email(email)
    User.where('lower(email) = ?', email.downcase).first
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
    update_attributes(deactivated_at: Time.now, avatar_kind: "initials")
    memberships.update_all(archived_at: Time.now)
    membership_requests.where("responded_at IS NULL").destroy_all
  end

  def deactivated?
    deactivated_at.present?
  end

  def active?
    deactivated_at.nil?
  end

  def reactivate!
    update_attribute(:deactivated_at, nil)
    archived_memberships.update_all(archived_at: nil)
  end

  # http://stackoverflow.com/questions/5140643/how-to-soft-delete-user-with-devise/8107966#8107966
  def active_for_authentication?
    super && !deactivated_at
  end

  def inactive_message
    I18n.t(:inactive_html, path_to_contact: '/contact').html_safe
  end

  def avatar_url(size = :medium)
    gravatar(size) || uploaded_avatar.url(size)
  end

  def gravatar(size = nil)
    gravatar_url size: IMAGE_SIZES.fetch(size, :medium) if self.avatar_kind == 'gravatar'
  end

  def locale
    selected_locale || detected_locale
  end

  def using_initials?
    avatar_kind == "initials"
  end

  def has_uploaded_image?
    uploaded_avatar.url(:medium) != '/avatars/medium/missing.png'
  end

  def has_gravatar?(options = {})
    hash = Digest::MD5.hexdigest(email.to_s.downcase)
    options = { :rating => 'x', :timeout => 2 }.merge(options)
    http = Net::HTTP.new('www.gravatar.com', 80)
    http.read_timeout = options[:timeout]
    response = http.request_head("/avatar/#{hash}?rating=#{options[:rating]}&default=http://gravatar.com/avatar")
    response.code != '302'
  rescue StandardError, Timeout::Error
    false  # Don't show "gravatar" if the service is down or slow
  end

  def generate_username
    return if name.blank? or username.present?

    if name.include? '@'
      #email used in place of name
      email_str = email.split("@").first
      new_username = email_str.parameterize.gsub(/[^a-z0-9]/, "")
    else
      new_username = name.parameterize.gsub(/[^a-z0-9]/, "")
    end
    username_tmp = new_username.dup.slice(0,18)
    num = 1
    while(User.where("username = ?", username_tmp).count > 0)
      break if username == username_tmp
      username_tmp = "#{new_username}#{num}"
      num+=1
    end
    self.username = username_tmp
  end

  def in_same_group_as?(other_user)
    (group_ids & other_user.group_ids).present?
  end

  def belongs_to_manual_subscription_group?
    groups.manual_subscription.any?
  end

  def show_start_group_button?
    !groups.cannot_start_parent_group.any?
  end

  private

  def set_default_avatar_kind
    if has_gravatar?
      self.avatar_kind = "gravatar"
    end
  end

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
