class Group < ActiveRecord::Base
  include ReadableUnguessableUrls
  AVAILABLE_BETA_FEATURES = ['discussion_iframe']
  include BetaFeatures

  class MaximumMembershipsExceeded < Exception
  end

  #even though we have permitted_params this needs to be here.. it's an issue brought about by one of the gems included.. i think the tree one

  attr_accessible :members_can_add_members, :members_can_edit_discussions, :members_can_edit_comments, :motions_can_be_edited,
                  :name, :parent, :parent_id, :description, :max_size,
                  :cannot_contribute, :full_name, :payment_plan, :parent_members_can_see_discussions,
                  :category_id, :max_size, :is_visible_to_parent_members, :is_visible_to_public,
                  :discussion_privacy_options, :membership_granted_upon, :visible_to,
                  :theme_id, :subdomain, :cover_photo, :logo, :members_can_raise_motions,
                  :members_can_vote, :members_can_start_discussions, :members_can_create_subgroups
  acts_as_tree

  PAYMENT_PLANS = ['pwyc', 'subscription', 'manual_subscription', 'undetermined']
  DISCUSSION_PRIVACY_OPTIONS = ['public_only', 'private_only', 'public_or_private']
  MEMBERSHIP_GRANTED_UPON_OPTIONS = ['request', 'approval', 'invitation']

  validates_presence_of :name
  validates_inclusion_of :payment_plan, in: PAYMENT_PLANS
  validates_inclusion_of :discussion_privacy_options, in: DISCUSSION_PRIVACY_OPTIONS
  validates_inclusion_of :membership_granted_upon, in: MEMBERSHIP_GRANTED_UPON_OPTIONS
  validates :description, length: { maximum: 250 }
  validates :name, length: { maximum: 250 }

  validate :limit_inheritance
  validate :validate_parent_members_can_see_discussions
  validate :validate_is_visible_to_parent_members
  validate :validate_discussion_privacy_options

  before_save :update_full_name_if_name_changed
  before_validation :set_discussions_private_only, if: :is_hidden_from_public?

  include PgSearch
  pg_search_scope :search_full_name, against: [:name, :description],
    using: {tsearch: {dictionary: "english"}}


  scope :categorised_any, -> { where('groups.category_id IS NOT NULL') }
  scope :in_category, -> (category) { where(category_id: category.id) }

  scope :archived, lambda { where('archived_at IS NOT NULL') }
  scope :published, lambda { where(archived_at: nil) }

  scope :parents_only, where(parent_id: nil)

  scope :sort_by_popularity, order('memberships_count DESC')

  scope :visible_to_public, published.where(is_visible_to_public: true)
  scope :hidden_from_public, published.where(is_visible_to_public: false)

  scope :visible_on_explore_front_page,
        -> { visible_to_public.categorised_any.parents_only.
             created_earlier_than(2.months.ago).
             active_discussions_since(1.month.ago).
             more_than_n_members(3).
             more_than_n_discussions(3).
             order('discussions.last_comment_at') }

  scope :include_admins, includes(:admins)

  scope :manual_subscription, -> { where(payment_plan: 'manual_subscription') }

  scope :cannot_start_parent_group, where(can_start_group: false)

  # Engagement (Email Template) Related Scopes
  scope :more_than_n_members, lambda { |n| where('memberships_count > ?', n) }
  scope :less_than_n_members, lambda { |n| where('memberships_count < ?', n) }
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
           conditions: {is_suspended: false},
           dependent: :destroy,
           extend: GroupMemberships

  has_many :all_memberships,
           dependent: :destroy,
           class_name: 'Membership',
           extend: GroupMemberships

  has_many :membership_requests,
           dependent: :destroy

  has_many :pending_membership_requests,
           class_name: 'MembershipRequest',
           conditions: {response: nil},
           dependent: :destroy

  has_many :admin_memberships,
           conditions: { admin: true },
           class_name: 'Membership',
           dependent: :destroy

  has_many :members,
           through: :memberships,
           source: :user

  has_many :pending_invitations, as: :invitable,
           class_name: 'Invitation',
           conditions: {accepted_at: nil, cancelled_at: nil}

  after_initialize :set_defaults

  alias :users :members

  has_many :requested_users, through: :membership_requests, source: :user
  has_many :admins, through: :admin_memberships, source: :user
  has_many :discussions, dependent: :destroy
  has_many :motions, through: :discussions

  belongs_to :parent, class_name: 'Group'
  belongs_to :category
  belongs_to :theme

  has_many :subgroups, class_name: 'Group', foreign_key: 'parent_id', conditions: { archived_at: nil }, order: 'name'

  has_one :subscription, dependent: :destroy

  delegate :include?, to: :users, prefix: true
  delegate :users, to: :parent, prefix: true
  delegate :members, to: :parent, prefix: true
  delegate :name, to: :parent, prefix: true

  paginates_per 20

  has_attached_file    :cover_photo,
                       styles: { desktop: "980x200#", card: "460x94#" },
                       default_url: '/assets/default-cover-photo.png'
  has_attached_file    :logo,
                       styles: { card: "67x67", medium: "100x100" },
                       default_url: '/assets/default-logo-:style.png'
  validates_attachment :cover_photo,
    size: { in: 0..10.megabytes },
    content_type: { content_type: /\Aimage/ },
    file_name: { matches: [/png\Z/i, /jpe?g\Z/i, /gif\Z/i] }
  validates_attachment :logo,
    size: { in: 0..10.megabytes },
    content_type: { content_type: /\Aimage/ },
    file_name: { matches: [/png\Z/i, /jpe?g\Z/i, /gif\Z/i] }

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

  def motions_count
    discussions.published.sum :motions_count
  end

  def archive!
    self.discussions.each(&:archive!)
    self.update_attribute(:archived_at, DateTime.now)
    memberships.update_all(archived_at: DateTime.now)
    subgroups.each do |group|
      group.archive!
    end
  end

  def is_archived?
    self.archived_at.present?
  end

  def is_hidden_from_public?
    !is_visible_to_public?
  end

  def is_subgroup_of_hidden_parent?
    is_subgroup? and parent.is_hidden_from_public?
  end

  def visible_to=(term)
    case term.to_s
    when 'public'
      self.is_visible_to_public = true
      self.is_visible_to_parent_members = false
    when 'parent_members'
      self.is_visible_to_public = false
      self.is_visible_to_parent_members = true
    when 'members'
      self.is_visible_to_public = false
      self.is_visible_to_parent_members = false
      self.discussion_privacy_options = 'private_only'
      self.membership_granted_upon = 'invitation'
    else
      raise "visible_to term not recognised: #{term}"
    end
  end

  def visible_to
    if is_visible_to_public?
      'public'
    elsif is_visible_to_parent_members?
      'parent_members'
    else
      'members'
    end
  end

  def membership_granted_upon_approval?
    membership_granted_upon == 'approval'
  end

  def membership_granted_upon_request?
    membership_granted_upon == 'request'
  end

  def membership_granted_upon_invitation?
    membership_granted_upon == 'invitation'
  end

  def is_parent?
    parent_id.blank?
  end

  def is_subgroup?
    !is_parent?
  end

  def admin_email
    admins.first.email
  end

  def membership_for(user)
    memberships.where("group_id = ? AND user_id = ?", id, user.id).first
  end

  def membership(user)
    membership_for(user)
  end

  def pending_membership_request_for(user)
    if user.is_logged_in?
      membership_requests.pending.where(requestor_id: user.id).first
    else
      false
    end
  end

  def private_discussions_only?
    discussion_privacy_options == 'private_only'
  end

  def public_discussions_only?
    discussion_privacy_options == 'public_only'
  end
  
  def public_or_private_discussions_allowed?
    discussion_privacy_options == 'public_or_private'
  end

  def discussion_private_default
    case discussion_privacy_options
    when 'public_or_private' then nil
    when 'public_only' then false
    when 'private_only' then true
    else
      raise "invalid discussion_privacy value"
    end
  end

  def add_member!(user, inviter=nil)
    if is_parent?
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
    membership = memberships.where(user_id: user.id).first
    membership ||= Membership.create!(group: self,
                                      user: user,
                                      inviter: inviter,
                                      subscribed_to_notification_emails: email_notification_default)
  end

  def user_membership_or_request_exists? user
    Membership.where(:user_id => user, :group_id => self).exists?
  end

  def invitations_remaining
    max_size - memberships_count - pending_invitations.count
  end
  
  def has_member_with_email?(email)
    members.where(email: email).any?
  end

  def has_membership_request_with_email?(email)
    membership_requests.where(email: email).any?
  end

  def is_setup?
    setup_completed_at.present?
  end

  def mark_as_setup!
    update_attribute(:setup_completed_at, Time.zone.now.utc)
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

  def group_request_description
    group_request.try :description
  end

  def parent_or_self
    if parent.present?
      parent
    else
      self
    end
  end

  def organisation_discussions_count
    Group.where("parent_id = ? OR (parent_id IS NULL AND id = ?)", parent_or_self.id, parent_or_self.id).sum(:discussions_count)
  end

  def organisation_motions_count
    Group.where("parent_id = ? OR (parent_id IS NULL AND id = ?)", parent_or_self.id, parent_or_self.id).all.sum(&:motions_count)
  end

  def has_subdomain?
    if is_subgroup?
      parent.has_subdomain?
    else
      subdomain.present?
    end
  end

  def subdomain
    if is_subgroup?
      parent.subdomain
    else
      super
    end
  end

  def theme
    if is_subgroup?
      parent.theme
    else
      super
    end
  end

  private
  def set_discussions_private_only
    self.discussion_privacy_options = 'private_only'
  end

  def validate_discussion_privacy_options
    unless is_visible_to_parent_members?
      if membership_granted_upon_request? and not public_discussions_only?
        self.errors.add(:discussion_privacy_options, "Discussions must be public if group is open")
      end
    end

    if is_hidden_from_public? and not private_discussions_only?
      self.errors.add(:discussion_privacy_options, "Discussions must be private if group is hidden")
    end
  end

  def validate_parent_members_can_see_discussions
    self.errors.add(:parent_members_can_see_discussions) unless parent_members_can_see_discussions_is_valid?
  end

  def validate_is_visible_to_parent_members
    self.errors.add(:is_visible_to_parent_members) unless visible_to_parent_members_is_valid?
  end

  def parent_members_can_see_discussions_is_valid?
    if parent_members_can_see_discussions?
      is_visible_to_parent_members?
    else
      true
    end
  end

  def visible_to_parent_members_is_valid?
    if is_visible_to_parent_members?
      is_hidden_from_public? and is_subgroup?
    else
      true
    end
  end

  def set_defaults
    self.discussion_privacy_options ||= 'public_or_private'
    self.membership_granted_upon ||= 'approval'
  end

  def calculate_full_name
    if is_parent?
      name
    else
      parent_name + " - " + name
    end
  end

  def limit_inheritance
    if parent_id.present?
      errors[:base] << "Can't set a subgroup as parent" unless parent.parent_id.nil?
    end
  end
end
