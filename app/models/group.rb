class Group < ActiveRecord::Base
  PERMISSION_CATEGORIES = [:everyone, :members, :admins, :parent_group_members]

  validates_presence_of :name
  validates_inclusion_of :viewable_by, in: PERMISSION_CATEGORIES
  validates_inclusion_of :members_invitable_by, in: PERMISSION_CATEGORIES
  validate :limit_inheritance

  validates_length_of :name, :maximum=>250
  validates :description, :length => { :maximum => 250 }

  after_initialize :set_defaults

  has_many :memberships,
    :conditions => {:access_level => Membership::MEMBER_ACCESS_LEVELS},
    :dependent => :destroy,
    :extend => GroupMemberships,
    :include => :user,
    :order => "LOWER(users.name)"
  has_many :membership_requests,
    :conditions => {:access_level => 'request'},
    :class_name => 'Membership'
  has_many :admin_memberships,
    :conditions => {:access_level => 'admin'},
    :class_name => 'Membership'
  has_many :users, :through => :memberships # TODO: rename to members
  has_many :requested_users, :through => :membership_requests, source: :user
  has_many :admins, through: :admin_memberships, source: :user
  has_many :discussions
  has_many :motions
  has_many :motions_voting,
           :through => :discussions,
           :source => :motions,
           :conditions => { phase: 'voting' }
  has_many :motions_closed,
           :through => :discussions,
           :source => :motions,
           :conditions => { phase: 'closed' }

  belongs_to :parent, :class_name => "Group"
  has_many :subgroups, :class_name => "Group", :foreign_key => 'parent_id'

  delegate :include?, :to => :users, :prefix => true
  delegate :users, :to => :parent, :prefix => true
  delegate :name, :to => :parent, :prefix => true

  acts_as_tagger

  attr_accessible :name, :viewable_by, :parent_id, :parent
  attr_accessible :members_invitable_by, :email_new_motion, :description

  #
  # ACCESSOR METHODS
  #

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

  def root_name
    if parent
      parent_name
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

  def add_member!(user, inviter=nil)
    unless users.exists?(user)
      unless membership = requested_users_include?(user)
        membership = memberships.build_for_user(user)
      end
      membership.access_level = 'member'
      membership.inviter = inviter
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

  def has_admin_user?(user)
    return true if admins.include?(user)
    return true if (parent && parent.admins.include?(user))
  end

  #
  # DISCUSSION LISTS
  #

  def all_discussions(user)
    if subgroups.present?
      result = discussions
      subgroups.each do |subgroup|
        if subgroup.users_include? user
          result += subgroup.discussions
        end
      end
      result.sort{ |a,b| b.latest_history_time <=> a.latest_history_time }
    else
      discussions.sort{ |a,b| b.latest_history_time <=> a.latest_history_time }
    end
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
