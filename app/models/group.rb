class Group < ActiveRecord::Base
  include ReadableUnguessableUrls

  class MaximumMembershipsExceeded < Exception
  end

  #even though we have permitted_params this needs to be here.. it's an issue
  attr_accessible :name, :privacy, :members_invitable_by, :parent, :parent_id, :description, :max_size, :cannot_contribute, :full_name, :payment_plan, :viewable_by_parent_members, :category_id, :max_size
  acts_as_tree

  PRIVACY_CATEGORIES = ['public', 'private', 'hidden']
  INVITER_CATEGORIES = ['members', 'admins']
  PAYMENT_PLANS = ['pwyc', 'subscription', 'manual_subscription', 'undetermined']
  validates_presence_of :name
  validates_inclusion_of :payment_plan, in: PAYMENT_PLANS
  validates_inclusion_of :privacy, in: PRIVACY_CATEGORIES
  validates_inclusion_of :members_invitable_by, in: INVITER_CATEGORIES
  validates :description, :length => { :maximum => 250 }
  validates :name, :length => { :maximum => 250 }

  validate :limit_inheritance
  validate :privacy_allowed_by_parent, if: :is_a_subgroup?
  validate :subgroups_are_hidden, if: :is_hidden?

  after_initialize :set_defaults
  before_save :update_full_name_if_name_changed

  include PgSearch
  pg_search_scope :search_full_name, against: [:name, :description],
    using: {tsearch: {dictionary: "english"}}

  scope :visible_on_explore_front_page, -> { categorised_any.parents_only }

  scope :categorised_any, -> { where('groups.category_id IS NOT NULL') }

  scope :archived, lambda { where('archived_at IS NOT NULL') }
  scope :published, lambda { where(archived_at: nil) }

  scope :parents_only, where(:parent_id => nil)

  scope :sort_by_popularity,
        order('memberships_count DESC')

  scope :visible_to_the_public,
        where(privacy: 'public').
        parents_only

  scope :manual_subscription, -> { where(payment_plan: 'manual_subscription') }

  scope :cannot_start_parent_group, where(can_start_group: false)

  # Engagement (Email Template) Related Scopes
  scope :more_than_n_members, lambda { |n| where('memberships_count > ?', n) }
  scope :more_than_n_discussions, lambda { |n| where('discussions_count > ?', n) }
  scope :less_than_n_discussions, lambda { |n| where('discussions_count < ?', n) }

  scope :no_active_discussions_since, lambda {|time|
    includes(:discussions).where('discussions.last_comment_at < ? OR discussions_count = 0', time)
  }

  scope :active_discussions_since, lambda {|time|
    includes(:discussions).where('discussions.last_comment_at > ?', time)
  }

  scope :created_earlier_than, lambda {|time| where('groups.created_at < ?', time) }

  scope :engaged, more_than_n_members(1).
                  more_than_n_discussions(2).
                  active_discussions_since(2.month.ago).
                  parents_only

  scope :engaged_but_stopped, more_than_n_members(1).
                              more_than_n_discussions(2).
                              no_active_discussions_since(2.month.ago).
                              created_earlier_than(2.months.ago).
                              parents_only

  scope :has_members_but_never_engaged, more_than_n_members(1).
                                    less_than_n_discussions(2).
                                    created_earlier_than(1.month.ago).
                                    parents_only

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

  has_many :pending_invitations, :as => :invitable,
           class_name: 'Invitation',
           conditions: {accepted_at: nil, cancelled_at: nil}

  alias :users :members

  has_many :requested_users, :through => :membership_requests, source: :user
  has_many :admins, through: :admin_memberships, source: :user
  has_many :discussions, :dependent => :destroy
  has_many :motions, :through => :discussions

  belongs_to :parent, :class_name => "Group"
  belongs_to :category
  has_many :subgroups, :class_name => "Group", :foreign_key => 'parent_id', conditions: { archived_at: nil }

  has_one :subscription, dependent: :destroy

  delegate :include?, :to => :users, :prefix => true
  delegate :users, :to => :parent, :prefix => true
  delegate :members, :to => :parent, :prefix => true
  delegate :name, :to => :parent, :prefix => true

  paginates_per 20

  def coordinators
    admins
  end

  def contact_person
    admins.order('id asc').first
  end

  def requestor_name_and_email
    "#{requestor_name} <#{requestor_email}>"
  end

  def requestor_name
    group_request.try(:admin_name)
  end

  def requestor_email
    group_request.try(:admin_email)
  end

  def voting_motions
    motions.voting
  end

  def closed_motions
    motions.closed
  end

  def archive!
    self.discussions.each(&:archive!)
    self.update_attribute(:archived_at, DateTime.now)
    memberships.update_all(:archived_at => DateTime.now)
    subgroups.each do |group|
      group.archive!
    end
  end

  def archived?
    self.archived_at.present?
  end

  def privacy_public?
    (privacy == 'public') and !archived?
  end

  def is_hidden?
    self.privacy == 'hidden'
  end

  def is_not_hidden?
    !is_hidden?
  end

  def parent_is_hidden?
    parent.is_hidden?
  end

  def members_can_invite_members?
    members_invitable_by == 'members'
  end

  def parent_members_visible_to(user)
    parent.users.sorted_by_name
  end

  # would be nice if the following 3 methods were reduced to just one - is_subgroup
  # parent and top_level are the less nice terms
  #
  def is_a_parent?
    parent_id.blank?
  end

  def is_top_level?
    is_a_parent?
  end

  def is_sub_group?
    !is_a_parent?
  end

  def is_a_subgroup?
    is_sub_group?
  end

  def admin_email
    admins.first.email
  end

  def membership(user)
    memberships.where("group_id = ? AND user_id = ?", id, user.id).first
  end

  def add_member!(user, inviter=nil)
    if is_a_parent?
      if (memberships_count.to_i > max_size.to_i)
        raise Group::MaximumMembershipsExceeded
      end
    end
    find_or_create_membership(user, inviter)
  end

  def add_members!(users, inviter=nil)
    users.map do |user|
      add_member!(user, inviter)
    end
  end

  def add_admin!(user, inviter = nil)
    membership = find_or_create_membership(user, inviter)
    membership.make_admin!
    membership
  end

  def find_or_create_membership(user, inviter)
    membership = memberships.where(:user_id => user).first
    membership ||= Membership.create!(group: self, user: user, inviter: inviter)
  end

  def has_admin_user?(user)
    admins.include?(user) || (parent && parent.admins.include?(user))
  end

  def user_membership_or_request_exists? user
    Membership.where(:user_id => user, :group_id => self).exists?
  end

  def user_is_a_parent_member? user
    parent.members.include? user
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

  def mark_as_setup!
    self.update_attribute(:setup_completed_at, Time.zone.now.utc)
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

  def has_subscription_plan?
    subscription.present?
  end

  def subscription_plan
    subscription.amount
  end

  def has_manual_subscription?
    payment_plan == 'manual_subscription'
  end

  def is_paying?
    (payment_plan == 'manual_subscription') ||
    (subscription.present? && subscription.amount > 0)
  end

  def is_hidden?
    privacy == "hidden"
  end

  private

  def calculate_full_name
    if is_a_parent?
      name
    else
      parent_name + " - " + name
    end
  end

  def set_defaults
    self.privacy ||= 'hidden'
    self.members_invitable_by ||= 'members'
  end

  def limit_inheritance
    if parent_id.present?
      errors[:base] << "Can't set a subgroup as parent" unless parent.parent_id.nil?
    end
  end

  def privacy_allowed_by_parent
    if parent && parent.privacy == 'hidden' && self.privacy != 'hidden'
      errors[:privacy] << "Parent group is hidden, subgroups must also be hidden"
    end
  end

  def subgroups_are_hidden
    unless subgroups.all?{|g| g.is_hidden?}
      errors[:privacy] << "There are non hidden subgroups, so this group cannot be hidden"
    end
  end
end
