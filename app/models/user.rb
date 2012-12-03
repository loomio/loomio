class User < ActiveRecord::Base

  require 'net/http'
  require 'digest/md5'

  LARGE_IMAGE = 170
  MED_LARGE_IMAGE = 70
  MEDIUM_IMAGE = 35
  SMALL_IMAGE = 25
  MAX_AVATAR_IMAGE_SIZE_CONST = 1000

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, #:registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

  validates :name, :presence => true
  validates :email, :presence => true

  validates_attachment :uploaded_avatar,
    :size => { :in => 0..User::MAX_AVATAR_IMAGE_SIZE_CONST.kilobytes },
    :content_type => { :content_type => ["image/jpeg", "image/jpg", "image/png", "image/gif"] }
  validates_uniqueness_of :username, :allow_nil => true, :allow_blank => true

  include Gravtastic
  gravtastic  :rating => 'pg',
              :default => 'none'

  has_attached_file :uploaded_avatar,
    :styles => {
      :large => "#{User::LARGE_IMAGE}x#{User::LARGE_IMAGE}#",
      :medlarge => "#{User::MED_LARGE_IMAGE}x#{User::MED_LARGE_IMAGE}#",
      :medium => "#{User::MEDIUM_IMAGE}x#{User::MEDIUM_IMAGE}#",
      :small => "#{User::SMALL_IMAGE}x#{User::SMALL_IMAGE}#"
    }
    # Use these to change image storage location
    #:url => "/system/:class/:attachment/:id/:style/:basename.:extension",
    #:path => ":rails_root/public/system/:class/:attachment/:id/:style/:basename.:extension"

  has_many :membership_requests,
           :conditions => { :access_level => 'request' },
           :class_name => 'Membership',
           :dependent => :destroy
  has_many :admin_memberships,
           :conditions => { :access_level => 'admin' },
           :class_name => 'Membership',
           :dependent => :destroy
  has_many :memberships,
           :conditions => { :access_level => Membership::MEMBER_ACCESS_LEVELS },
           :dependent => :destroy

  has_many :groups,
           :through => :memberships
  has_many :adminable_groups,
           :through => :admin_memberships,
           :class_name => 'Group',
           :source => :group
  has_many :group_requests,
           :through => :membership_requests,
           :class_name => 'Group',
           :source => :group

  has_many :discussions,
           :through => :groups
  has_many :authored_discussions,
           :class_name => 'Discussion',
           :foreign_key => 'author_id'

  has_many :motions,
           :through => :discussions
  has_many :authored_motions,
           :class_name => 'Motion',
           :foreign_key => 'author_id'
  has_many :motions_in_voting_phase,
           :through => :discussions,
           :source => :motions,
           :conditions => { phase: 'voting' }
  has_many :motions_closed,
           :through => :discussions,
           :source => :motions,
           :conditions => { phase: 'closed' },
           :order => 'close_date DESC'

  has_many :votes
  has_many :open_votes,
           :class_name => 'Vote',
           :source => :votes,
           :through => :motions_in_voting_phase

  has_many :notifications

  has_many :discussion_read_logs,
           :dependent => :destroy

  has_many :motion_read_logs,
           :dependent => :destroy

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :avatar_kind, :email, :password, :password_confirmation, :remember_me,
                  :uploaded_avatar, :username, :subscribed_to_daily_activity_email, :subscribed_to_proposal_closure_notifications, 
                  :subscribed_to_mention_notifications

  before_save :ensure_authentication_token
  after_create :ensure_name_entry
  before_save :set_avatar_initials

  scope :daily_activity_email_recipients, where({subscribed_to_daily_activity_email: true})

  #scope :unviewed_notifications, notifications.where('viewed_at IS NULL')

  def get_vote_for(motion)
    Vote.where('motion_id = ? AND user_id = ?', motion.id, id).last
  end

  def get_position_for(motion)
    vote = Vote.where('motion_id = ? AND user_id = ?', motion.id, id).last
    vote.position if vote
  end

  def voted?(motion)
    Vote.where('motion_id = ? AND user_id = ?', motion.id, id).exists?
  end

  def is_group_admin?(group)
    memberships.for_group(group).with_access('admin').exists?
  end

  def is_group_member?(group)
    memberships.for_group(group).exists?
  end

  def group_membership(group)
    memberships.for_group(group).first
  end

  def unviewed_notifications
    notifications.unviewed
  end

  # Returns most recent notifications
  #   lower_limit - (minimum # of notifications returned)
  #   upper_limit - (maximum # of notifications returned)
  def recent_notifications(lower_limit=10, upper_limit=25)
    if unviewed_notifications.count < lower_limit
      notifications.limit(lower_limit)
    else
      unviewed_notifications.limit(upper_limit)
    end
  end

  def mark_notifications_as_viewed!(latest_viewed_id)
    unviewed_notifications.where("id <= ?", latest_viewed_id).
      update_all(:viewed_at => Time.now)
  end

  def self.invite_and_notify!(user_params, inviter, group)
    new_user = User.invite!(user_params, inviter) do |u|
      u.skip_invitation = true
    end
    if new_user.errors.empty?
      membership = group.add_member! new_user, inviter
      UserMailer.invited_to_loomio(new_user, inviter, group).deliver
    end
    new_user
  end

  def discussions_with_current_motion_not_voted_on
    if discussions
      (discussions.includes(:motions).where('motions.phase = ?', "voting") -  discussions_with_current_motion_voted_on)
    else
      []
    end
  end

  def discussions_with_current_motion_voted_on
    if discussions
      (discussions.includes(:motions => :votes).where('motions.phase = ? AND votes.user_id = ?', "voting", id))
    else
      []
    end
  end

  def discussions_sorted
    discussions
      .where("discussions.id NOT IN (SELECT discussion_id FROM motions WHERE phase = 'voting')")
      .order("last_comment_at DESC")
  end

  def self.loomio_helper_bot
    helper_bot = User.find_or_create_by_email('contact@loom.io')
    unless helper_bot.persisted?
      helper_bot.name = "Loomio Helper Bot"
      helper_bot.password = SecureRandom.hex(16)
      helper_bot.save
    end
    helper_bot
  end

  def update_motion_read_log(motion)
    log = MotionReadLog.where('motion_id = ? AND user_id = ?', motion.id, id).first
    if log.nil?
      motion_read_log = MotionReadLog.new
      motion_read_log.user_id = id
      motion_read_log.motion_id = motion.id
      motion_read_log.save!
    else
      log.motion_last_viewed_at = Time.now
      log.save!
    end
  end

  def update_discussion_read_log(discussion)
    log = DiscussionReadLog.where('discussion_id = ? AND user_id = ?', discussion.id, id).first
    if log.nil?
      discussion_read_log = DiscussionReadLog.new
      discussion_read_log.discussion_last_viewed_at = Time.now
      discussion_read_log.user_id = id
      discussion_read_log.discussion_id = discussion.id
      discussion_read_log.save!
    else
      log.discussion_last_viewed_at = Time.now
      log.save!
    end
  end

  def update_group_last_viewed_at(group)
    membership = group_membership(group)
    if membership
      membership.group_last_viewed_at = Time.now()
      membership.save!
    end
  end

  def self.find_by_email(email)
    User.find(:first, :conditions => ["lower(email) = ?", email.downcase])
  end

  def subgroups
    groups.where("parent_id IS NOT NULL")
  end

  def root_groups
    groups.where("parent_id IS NULL").find(:all, :order => "LOWER(name)")
  end

  def position(motion)
    if motion.user_has_voted?(self)
      get_vote_for(motion).position
    end
  end

  def name
    deleted_at ? "Deleted user" : read_attribute(:name)
  end

  def deactivate!
    update_attribute(:deleted_at, 1.month.ago)
  end

  def activate!
    update_attribute(:deleted_at, nil)
  end

  # http://stackoverflow.com/questions/5140643/how-to-soft-delete-user-with-devise/8107966#8107966
  def active_for_authentication?
    super && !deleted_at
  end

  def gravatar?(email, options = {})
    hash = Digest::MD5.hexdigest(email.to_s.downcase)
    options = { :rating => 'x', :timeout => 2 }.merge(options)
    http = Net::HTTP.new('www.gravatar.com', 80)
    http.read_timeout = options[:timeout]
    response = http.request_head("/avatar/#{hash}?rating=#{options[:rating]}&default=http://gravatar.com/avatar")
    response.code != '302'
  rescue StandardError, Timeout::Error
    false  # Don't show "gravatar" if the service is down or slow
  end

  def avatar_url(size = :medium)
    size = size.to_sym
    case size
    when :small
      pixels = User::SMALL_IMAGE
    when :medium
      pixels = User::MEDIUM_IMAGE
    when :medlarge
      pixels = User::MED_LARGE_IMAGE
    when :large
      pixels = User::LARGE_IMAGE
    else
      pixels = User::SMALL_IMAGE
    end
    if avatar_kind == "gravatar"
      gravatar_url(:size => pixels)
    elsif avatar_kind == "uploaded"
      uploaded_avatar.url(size)
    end
  end

  def set_avatar_initials
    initials = ""
    if  name.blank? || name == email
      initials = email[0..1]
    else
      name.split.each { |name| initials += name[0] }
    end
    initials = initials.upcase.gsub(/ /, '')
    initials = "DU" if deleted_at
    self.avatar_initials = initials[0..2]
  end

  def generate_username
    ensure_name_entry if name.nil?
    if name.include? '@'
      #email used in place of name
      email_str = email.split("@").first 
      new_username = email_str.gsub(/\s+/, "").downcase
    else
      new_username = name.gsub(/\s+/, "").downcase
    end
    username_tmp = new_username.dup
    num = 1
    while(User.where("username = ?", username_tmp).count > 0)
      username_tmp = "#{new_username}#{num}"
      num+=1
    end
    self.username = username_tmp
    save
  end

  private
    def ensure_name_entry
      unless name
        self.name = email
        save
      end
    end

end
