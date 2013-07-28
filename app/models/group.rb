class Group < ActiveRecord::Base

  PERMISSION_CATEGORIES = ['everyone', 'members', 'admins', 'parent_group_members']

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
    :dependent => :destroy

  has_many :pending_membership_requests,
           class_name: 'MembershipRequest',
           conditions: {response: nil},
           dependent: :destroy

  has_many :admin_memberships,
    :conditions => {:access_level => 'admin'},
    :class_name => 'Membership',
    :dependent => :destroy

  has_many :members,
           through: :memberships,
           source: :user

  has_many :pending_invitations,
           class_name: 'Invitation',
           conditions: {accepted_at: nil, cancelled_at: nil}

  alias :users :members

  has_many :requested_users, :through => :membership_requests, source: :user
  has_many :admins, through: :admin_memberships, source: :user
  has_many :discussions, :dependent => :destroy
  has_many :motions, :through => :discussions

  belongs_to :parent, :class_name => "Group"
  has_many :subgroups, :class_name => "Group", :foreign_key => 'parent_id'

  delegate :include?, :to => :users, :prefix => true
  delegate :users, :to => :parent, :prefix => true
  delegate :name, :to => :parent, :prefix => true

  paginates_per 20

  def voting_motions
    motions.voting
  end

  def closed_motions
    motions.closed
  end

  def archive!
    self.update_attribute(:archived_at, DateTime.now)
    memberships.update_all(:archived_at => DateTime.now)
    subgroups.each do |group|
      group.archive!
    end
  end

  def archived?
    self.archived_at.present?
  end

  def viewable_by?(user)
    Ability.new(user).can?(:show, self)
  end

  def members_can_invite?
    members_invitable_by == 'members'
  end

  def parent_members_visible_to(user)
    parent.users.sorted_by_name
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

  def has_member_with_email?(email)
    users.where('email = ?', email).present?
  end

  def has_membership_request_with_email?(email)
    membership_requests.where('email = ?', email).present?
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
      self.viewable_by ||= 'parent_group_members'
    else
      self.viewable_by ||= 'members'
    end
    self.members_invitable_by ||= 'members'
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
