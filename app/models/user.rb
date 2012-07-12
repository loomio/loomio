class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, #:registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :name, :presence => true
  
  include Gravtastic
  gravtastic :rating => 'pg'
  
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
  has_many :motions_voting,
           :through => :discussions,
           :source => :motions,
           :conditions => { phase: 'voting' }
  has_many :motions_closed,
           :through => :discussions,
           :source => :motions,
           :conditions => { phase: 'closed' }

  has_many :votes

  has_many :discussion_read_logs,
           :dependent => :destroy

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :avatar_kind, :email, :password, :password_confirmation, :remember_me
  
  # Settings for paperclip
  attr_accessible :uploaded_avatar
  has_attached_file :uploaded_avatar, 
    :styles => { 
      :medium => "170x170#", 
      :thumb => "40x40#"
    }
    #:url => "/system/:class/:attachment/:id/:style/:basename.:extension",
    #:path => ":rails_root/public/system/:class/:attachment/:id/:style/:basename.:extension"
    
  validates_attachment :uploaded_avatar, 
    :size => { :in => 0..1000.kilobytes }
  # File types can be restricted
  # :content_type => { :content_type => "image/jpg" },
    
  acts_as_taggable_on :group_tags
  after_create :ensure_name_entry

  def get_vote_for(motion)
    Vote.where('motion_id = ? AND user_id = ?', motion.id, id).last
  end

  def voted?(motion)
    Vote.where('motion_id = ? AND user_id = ?', motion.id, id).exists?
  end

  def motions_voted
    motions_voting.that_user_has_voted_on(self)
  end

  def motions_not_voted
    motions_voting.that_user_has_not_voted_on(self)
  end

  def group_motions_voted(group)
    group.motions_voting.that_user_has_voted_on(self)
  end

  def group_motions_not_voted(group)
    group.motions_voting.that_user_has_not_voted_on(self)
  end

  def is_group_admin?(group)
    memberships.for_group(group).with_access('admin').exists?
  end

  def group_membership(group)
    memberships.for_group(group).first
  end

  def self.invite_and_notify!(user_params, inviter, group)
    new_user = User.invite!(user_params, inviter) do |u|
      u.skip_invitation = true
    end
    group.add_member! new_user
    UserMailer.invited_to_loomio(new_user, inviter, group).deliver
    new_user
  end

  def discussions_sorted
    discussions.sort{ |a,b| b.latest_history_time <=> a.latest_history_time }
  end

  def update_discussion_read_log(discussion)
    if DiscussionReadLog.where('discussion_id = ? AND user_id = ?', discussion.id, id).first == nil
      discussion_read_log = DiscussionReadLog.new
      discussion_read_log.discussion_activity_when_last_read = discussion.activity
      discussion_read_log.user_id = id
      discussion_read_log.discussion_id = discussion.id
      discussion_read_log.save
    else
      log = DiscussionReadLog.where('discussion_id = ? AND user_id = ?', discussion.id, id).first
      log.discussion_activity_when_last_read = discussion.activity
      log.save
    end
  end

  def discussion_activity_when_last_read(discussion)
    log = DiscussionReadLog.where('discussion_id = ? AND user_id = ?', discussion.id, id).first
    if log
      log.discussion_activity_when_last_read
    else
      0
    end
  end

  def discussion_activity_count(discussion)
    discussion.activity - discussion_activity_when_last_read(discussion)
  end

  def self.find_by_email(email)
    User.find(:first, :conditions => ["lower(email) = ?", email.downcase])
  end

  # Get all root groups that the user belongs to
  # This also includes parent groups of sub-groups
  # that the user belongs to (even though the user
  # might not necessarily belong to the parent)
  def all_root_groups
    results = root_groups
    subgroups.each do |subgroup|
      unless results.include? subgroup.parent
        results << subgroup.parent
      end
    end
    results.sort_by { |group| group.name }
  end

  def subgroups
    groups.where("parent_id IS NOT NULL")
  end

  def root_groups
    groups.where("parent_id IS NULL")
  end

  def position(motion)
    if motion.user_has_voted?(self)
      get_vote_for(motion).position
    end
  end

  def name
    deleted_at ? "Deleted user" : read_attribute(:name)
  end
  
  def initials
    initials = ""
    read_attribute(:name) == read_attribute(:email) ? initials = read_attribute(:email)[0..1] : 
        read_attribute(:name).gsub(/(?:^|\s|-|')[A-Z,a-z]/) { |first_character| initials += first_character }
    
    deleted_at ? "DU" : initials.upcase.gsub(/ /, '')
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

  def activity_total
    total = 0;
    groups.each do |group|
      total += activity_total_in(group)
    end
    total
  end

  def activity_total_in(group)
    total = 0
    group.discussions.each do |discussion|
      total += discussion_activity_count(discussion)
    end
    total
  end
  
  def avatar_url(size = "thumb")
    case size
    when "thumb"
      pixels = "40"
    when "medium"
      pixels = "170"
    else 
      pixels = "40"
    end
    
    if avatar_kind == "gravatar"
      self.gravatar_url(:size => pixels)
    elsif avatar_kind == "uploaded"
      self.uploaded_avatar.url(size)
    end
  end

  private
    def ensure_name_entry
      unless name
        self.name = email
        save
      end
    end
end
