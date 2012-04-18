class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me

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

  has_many :motions, through: :groups
  has_many :motions_discussing, through: :groups, :source => :motions, :conditions => {phase: 'discussion'}
  has_many :motions_voting, through: :groups, :source => :motions, :conditions => {phase: 'voting'}
  has_many :motions_closed, through: :groups, :source => :motions, :conditions => {phase: 'closed'}

  has_many :motion_activity_read_logs

  acts_as_taggable_on :group_tags
  after_create :ensure_name_entry

  def motion_vote(motion)
    Vote.where('motion_id = ? AND user_id = ?', motion.id, id).first
  end

  def is_group_admin?(group)
    memberships.for_group(group).with_access('admin').exists?
  end

  def group_membership(group)
    memberships.for_group(@group).first
  end

  def self.invite_and_notify!(user_params, inviter, group)
    new_user = User.invite!(user_params, inviter) do |u|
      u.skip_invitation = true
    end
    group.add_member! new_user
  UserMailer.invited_to_loomio(new_user, inviter, group).deliver
  new_user
  end

  def update_motion_read_log(motion)
    if MotionReadLog.where('motion_id = ? AND user_id = ?', motion.id, id).first == nil
      MotionReadLog.create(vote_activity_when_last_read: motion.vote_activity, discussion_activity_when_last_read: motion.discussion_activity, user_id: id, motion_id: motion.id)
    else
      log = MotionReadLog.where('motion_id = ? AND user_id = ?', motion.id, id).first
      log.vote_activity_when_last_read = motion.vote_activity
      log.discussion_activity_when_last_read = motion.discussion_activity
      log.save
    end
  end

  def vote_activity_when_last_read(motion)
    log = MotionReadLog.where('motion_id = ? AND user_id = ?', motion.id, id).first
    if log
      log.vote_activity_when_last_read
    else
      0
    end
  end

  def discussion_activity_when_last_read(motion)
    log = MotionReadLog.where('motion_id = ? AND user_id = ?', motion.id, id).first
    if log
      log.discussion_activity_when_last_read
    else
      0
    end
  end

  def vote_activity_count(motion)
    motion.vote_activity - vote_activity_when_last_read(motion)
  end

  def discussion_activity_count(motion)
    motion.discussion_activity - discussion_activity_when_last_read(motion)
  end

  private
    def ensure_name_entry
      unless name
        self.name = email
        save
      end
    end
end
