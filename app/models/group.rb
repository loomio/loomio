class Group < ActiveRecord::Base
  PERMISSION_CATEGORIES = [:everyone, :members, :admins, :parent_group_members]

  validates_presence_of :name
  validates_inclusion_of :viewable_by, in: PERMISSION_CATEGORIES
  validates_inclusion_of :members_invitable_by, in: PERMISSION_CATEGORIES
  validate :limit_inheritance
  after_initialize :set_defaults

  has_many :memberships,
    :conditions => {:access_level => Membership::MEMBER_ACCESS_LEVELS},
    :dependent => :destroy,
    :extend => GroupMemberships
  has_many :membership_requests,
    :conditions => {:access_level => 'request'},
    :class_name => 'Membership'
  has_many :admin_memberships,
    :conditions => {:access_level => 'admin'},
    :class_name => 'Membership'
  has_many :users, :through => :memberships # TODO: rename to members
  has_many :requested_users, :through => :membership_requests, source: :user
  has_many :admins, through: :admin_memberships, source: :user
  has_many :motions
  has_many :discussions

  belongs_to :parent, :class_name => "Group"
  has_many :subgroups, :class_name => "Group", :foreign_key => 'parent_id'

  delegate :include?, :to => :users, :prefix => true
  delegate :users, :to => :parent, :prefix => true
  delegate :name, :to => :parent, :prefix => true

  acts_as_tagger

  attr_accessible :name, :viewable_by, :parent_id, :parent
  attr_accessible :members_invitable_by, :email_new_motion

  #
  # ACCESSOR METHODS
  #

  def viewable_by
    value = read_attribute(:viewable_by)
    value.to_sym if value.present?
  end

  def viewable_by=(value)
    write_attribute(:viewable_by, value.to_s)
  end

  def members_invitable_by
    value = read_attribute(:members_invitable_by)
    value.to_sym if value.present?
  end

  def members_invitable_by=(value)
    write_attribute(:members_invitable_by, value.to_s)
  end

  def full_name(separator= " - ")
    if parent
      parent_name + separator + name
    else
      name
    end
  end

  def users_sorted
    users.sort { |a,b| a.name.downcase <=> b.name.downcase }
  end


  #
  # MEMBERSHIP METHODS
  #

  def add_request!(user)
    unless requested_users_include?(user) || users.exists?(user)
      if parent.nil? || user.group_membership(parent)
        membership = memberships.build_for_user(user, access_level: 'request')
        membership.save!
        GroupMailer.new_membership_request(membership).deliver
        reload
        membership
      end
    end
  end

  def add_member!(user)
    unless users.exists?(user)
      unless membership = requested_users_include?(user)
        membership = memberships.build_for_user(user)
      end
      membership.access_level = 'member'
      membership.save!
      reload
      membership
    end
  end

  def add_admin!(user)
    unless (membership = memberships.find_by_user_id(user) ||
            membership = membership_requests.find_by_user_id(user))
      membership = memberships.build_for_user(user)
    end
    membership.access_level = 'admin'
    membership.save!
    reload
    membership
  end


  #
  # PERMISSION-CHECKS
  #

  def requested_users_include?(user)
    membership_requests.find_by_user_id(user)
  end

  def can_be_edited_by?(user)
    has_admin_user?(user)
  end

  def has_admin_user?(user)
    return true if admins.include?(user)
    return true if (parent && parent.admins.include?(user))
  end

  def can_be_viewed_by?(user)
    return true if viewable_by == :everyone
    return true if users.include?(user)
    return true if viewable_by == :parent_group_members && (parent.users || []).include?(user)
  end

  def can_invite_members?(user)
    if members_invitable_by == :members
      return true if users.include?(user)
    elsif members_invitable_by == :admins
      return true if has_admin_user?(user)
    end
  end

  def discussions_sorted
    discussions.sort{ |a,b| b.latest_history_time <=> a.latest_history_time }
  end

  #
  # PRIVATE METHODS
  #

  private

  def set_defaults
    self.viewable_by ||= :everyone if parent.nil?
    self.viewable_by ||= :parent_group_members unless parent.nil?
    self.members_invitable_by ||= :members
  end

  # Validators
  def limit_inheritance
    unless parent.nil?
      errors[:base] << "Can't set a subgroup as parent" unless parent.parent.nil?
    end
  end
end
