class Membership < ActiveRecord::Base
  ACCESS_LEVELS = ['member', 'admin']
  MEMBER_ACCESS_LEVELS = ['member', 'admin']

  validates_presence_of :group, :user
  validates_inclusion_of :access_level, :in => ACCESS_LEVELS
  validates_uniqueness_of :user_id, :scope => :group_id

  belongs_to :group, :counter_cache => true
  belongs_to :user, :counter_cache => true
  belongs_to :inviter, :class_name => "User"
  has_many :events, :as => :eventable, :dependent => :destroy

  scope :archived, lambda { where('archived_at IS NOT NULL') }
  scope :published, lambda { where(archived_at: nil) }

  scope :for_group, lambda {|group| where(:group_id => group)}
  scope :with_access, lambda {|access| where(:access_level => access)}

  delegate :name, :email, :to => :user, :prefix => :user
  delegate :parent, :to => :group, :prefix => :group, :allow_nil => true
  delegate :name, :full_name, :to => :group, :prefix => :group
  delegate :admins, :to => :group, :prefix => :group
  delegate :name, :to => :inviter, :prefix => :inviter, :allow_nil => true

  before_create :set_group_last_viewed_at_to_now
  before_create :check_group_max_size
  after_initialize :set_defaults
  before_destroy :remove_open_votes
  after_destroy :destroy_subgroup_memberships

  include AASM
  aasm :column => :access_level do
    state :member, initial: true
    state :admin

    event :make_admin do
      transitions :to => :admin, :from => [:member, :admin]
    end
    event :remove_admin do
      transitions :to => :member, :from => [:admin]
    end
  end

  def group_has_multiple_admins?
    group.admins.count > 1
  end

  def user_name_or_email
    return user_name ? user_name : user_email
  end

  def admin?
    access_level == 'admin'
  end


  private

  def check_group_max_size
    if group.max_size
      raise "Group max_size exceeded" if group.memberships_count >= group.max_size
    end
  end

  def set_group_last_viewed_at_to_now
    self.group_last_viewed_at = Time.now
  end

  def destroy_subgroup_memberships
    return if group.nil? #necessary if group is missing (as in case of production data)
    group.subgroups.each do |subgroup|
      subgroup.memberships.where(user_id: user.id).destroy_all
    end
  end

  def remove_open_votes
    return if group.nil? #necessary if group is missing (as in case of production data)
    group.motions.voting.each do |motion|
      motion.votes.where(user_id: user.id).each(&:destroy)
    end
  end

  def set_defaults
    self.access_level ||= 'member'
  end
end
