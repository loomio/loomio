class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, #:registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :name, :presence => true

  has_many :membership_requests,
           :conditions => {:access_level => 'request'},
           :class_name => 'Membership'
  has_many :memberships,
           :conditions => {:access_level => Membership::MEMBER_ACCESS_LEVELS},
           :dependent => :destroy
  has_many :groups, through: :memberships
  has_many :group_requests, through: :membership_requests, class_name: 'Group', source: :group
  has_many :votes

  has_many :discussions, through: :groups
  has_many :motions, through: :discussions
  has_many :motions_voting, through: :discussions, :source => :motions, :conditions => {phase: 'voting'}
  has_many :motions_closed, through: :discussions, :source => :motions, :conditions => {phase: 'closed'}

  has_many :discussion_read_logs,
           :dependent => :destroy

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me

  acts_as_taggable_on :group_tags
  after_create :ensure_name_entry

  def motion_vote(motion)
    Vote.where('motion_id = ? AND user_id = ?', motion.id, id).last
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
    results
  end

  def subgroups
    groups.where("parent_id IS NOT NULL")
  end

  def root_groups
    groups.where("parent_id IS NULL")
  end

  def position(motion)
    if motion.user_has_voted?(self)
      motion_vote(motion).position
    end
  end
  
  def name
    if deleted_at
      'Deleted User'
    else
      name
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
