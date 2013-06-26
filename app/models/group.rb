class Group < ActiveRecord::Base

  PERMISSION_CATEGORIES = [:everyone, :members, :admins, :parent_group_members]

  attr_accessible :name, :viewable_by, :parent_id, :parent, :cannot_contribute,
                  :members_invitable_by, :email_new_motion, :description, :setup_completed_at,
                  :next_steps_completed, :paying_subscription

  validates_presence_of :name
  validates_inclusion_of :viewable_by, in: PERMISSION_CATEGORIES
  validates_inclusion_of :members_invitable_by, in: PERMISSION_CATEGORIES
  validates :description, :length => { :maximum => 250 }
  validates :name, :length => { :maximum => 250 }
  validates :max_size, presence: true, if: :is_a_parent?

  validate :limit_inheritance
  validate :max_size_is_nil, if: :is_a_subgroup?

  after_initialize :set_defaults
  before_validation :set_max_group_size, on: :create
  before_save :update_full_name_if_name_changed

  default_scope where(:archived_at => nil)

  scope :parents_only, where(:parent_id => nil)
  scope :visible_to_the_public,
        where(viewable_by: 'everyone').
        where('memberships_count > 4').
        order(:full_name)

  scope :search_full_name, lambda { |query| where("full_name ILIKE ?", "%#{query}%") }

  has_one :group_request

  has_many :memberships,
    :conditions => {:access_level => Membership::MEMBER_ACCESS_LEVELS},
    :dependent => :destroy,
    :extend => GroupMemberships

  has_many :membership_requests,
    :conditions => {:access_level => 'request'},
    :class_name => 'Membership',
    :dependent => :destroy

  has_many :admin_memberships,
    :conditions => {:access_level => 'admin'},
    :class_name => 'Membership',
    :dependent => :destroy

  has_many :members,
           through: :memberships,
           source: :user,
           conditions: { :invitation_token => nil }

  has_many :pending_invitations,
           class_name: 'Invitation',
           conditions: {accepted_at: nil, cancelled_at: nil}

  alias :users :members

  has_many :requested_users, :through => :membership_requests, source: :user
  has_many :admins, through: :admin_memberships, source: :user
  has_many :discussions, :dependent => :destroy
  has_many :motions, :through => :discussions
  has_many :motions_in_voting_phase,
           :through => :discussions,
           :source => :motions,
           :conditions => { phase: 'voting' },
           :order => 'close_at'
  has_many :motions_closed,
           :through => :discussions,
           :source => :motions,
           :conditions => { phase: 'closed' },
           :order => 'close_at DESC'

  belongs_to :parent, :class_name => "Group"
  has_many :subgroups, :class_name => "Group", :foreign_key => 'parent_id'

  delegate :include?, :to => :users, :prefix => true
  delegate :users, :to => :parent, :prefix => true
  delegate :name, :to => :parent, :prefix => true

  paginates_per 20

  def archive!
    self.update_attribute(:archived_at, DateTime.now)
    memberships.update_all(:archived_at => DateTime.now)
    subgroups.each do |group|
      group.archive!
    end
  end

  def beta_features
    if parent && (parent.beta_features == true)
      true
    else
      self[:beta_features]
    end
  end

  def beta_features?
    beta_features
  end

  def viewable_by
    value = read_attribute(:viewable_by)
    value.to_sym if value.present?
  end

  def viewable_by=(value)
    write_attribute(:viewable_by, value.to_s)
  end

  def members_can_invite?
    members_invitable_by == :members
  end

  def members_invitable_by
    value = read_attribute(:members_invitable_by)
    value.to_sym if value.present?
  end

  def members_invitable_by=(value)
    write_attribute(:members_invitable_by, value.to_s)
  end

  def root_name
    if parent
      parent_name
    else
      name
    end
  end

  def parent_members_visible_to(user)
    parent.users.sorted_by_name
  end

  def activity_since_last_viewed?(user)
    membership = membership(user)
    if membership
      new_comments_since_last_looked_at_group = discussions
        .includes(:comments)
        .where('comments.user_id <> ? AND comments.created_at > ?' , user.id, membership.group_last_viewed_at)
        .count > 0
      new_comments_since_last_looked_at_discussions = discussions
        .joins('INNER JOIN discussion_read_logs ON discussions.id = discussion_read_logs.discussion_id')
        .where('discussion_read_logs.user_id = ? AND discussions.last_comment_at > discussion_read_logs.discussion_last_viewed_at',  user.id)
        .count > 0
      unread_comments = new_comments_since_last_looked_at_group &&
                        new_comments_since_last_looked_at_discussions

      # TODO: Refactor this to an active record query and write tests for it
      unread_new_discussions = Discussion.find_by_sql(["
        (SELECT discussions.id FROM discussions WHERE group_id = ? AND discussions.created_at > ?)
        EXCEPT
        (SELECT discussions.id FROM discussions
         INNER JOIN discussion_read_logs ON discussions.id = discussion_read_logs.discussion_id
         WHERE discussions.group_id = ? AND discussion_read_logs.user_id = ?);",
        id, membership.group_last_viewed_at, id, user.id])

      return true if unread_comments || unread_new_discussions.present?
    end
    false
  end


  # would be nice if the following 4 methods were reduced to just one - is_sub_group
  # parent and top_level are the less nice terms
  #
  def is_top_level?
    parent.blank?
  end

  def is_sub_group?
    parent.present?
  end

  def is_a_parent?
    parent.nil?
  end

  def is_a_subgroup?
    parent.present?
  end

  def admin_email
    admins.first.email
  end

  def membership(user)
    memberships.where("group_id = ? AND user_id = ?", id, user.id).first
  end

  def add_request!(user)
    if user_can_join?(user) && !user_membership_or_request_exists?(user)
      membership = user.memberships.create!(:group_id => id)
      membership
    end
  end

  def add_member!(user, inviter=nil)
    membership = find_or_build_membership_for_user(user)
    membership.promote_to_member!(inviter)
    membership
  end

  def add_admin!(user, inviter = nil)
    membership = find_or_build_membership_for_user(user)
    membership.make_admin!
    membership.inviter = inviter if inviter.present?
    membership
  end

  def find_or_build_membership_for_user(user)
    membership = Membership.where(:user_id => user, :group_id => self).first
    membership ||= user.memberships.build(:group_id => id)
  end

  def has_admin_user?(user)
    return true if admins.include?(user)
    return true if (parent && parent.admins.include?(user))
  end

  def user_membership_or_request_exists? user
    Membership.where(:user_id => user, :group_id => self).exists?
  end

  def user_can_join? user
    is_a_parent? || user_is_a_parent_member?(user)
  end

  def is_a_parent?
    parent_id.nil?
  end

  def is_a_subgroup?
    parent_id.present?
  end

  def user_is_a_parent_member? user
    user.group_membership(parent)
  end

  def invitations_remaining
    max_size - memberships_count - pending_invitations.count
  end

  def is_setup?
    self.setup_completed_at.present?
  end

  def update_full_name_if_name_changed
    if changes.include?('name')
      update_full_name
      subgroups.each do |subgroup|
        subgroup.full_name = name + " - " + subgroup.name
        subgroup.save(validate: false)
      end
    end
  end

  def update_full_name
    self.full_name = calculate_full_name
  end

  private

  def calculate_full_name
    if is_a_parent?
      name
    else
      parent_name + " - " + name
    end
  end

  def set_max_group_size
    self.max_size = 50 if (is_a_parent? && max_size.nil?)
  end

  def set_defaults
    if is_a_subgroup?
      self.viewable_by ||= :parent_group_members
    else
      self.viewable_by ||= :members
    end
    self.members_invitable_by ||= :members
  end

  def limit_inheritance
    unless parent_id.nil?
      errors[:base] << "Can't set a subgroup as parent" unless parent.parent_id.nil?
    end
  end

  def max_size_is_nil
    unless max_size.nil?
      errors.add(:max_size, "Cannot be nil")
    end
  end
end
