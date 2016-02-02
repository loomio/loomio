class Group < ActiveRecord::Base
  include ReadableUnguessableUrls
  include BetaFeatures
  include HasTimeframe
  include MessageChannel
  include DeprecatedGroupFeatures
  AVAILABLE_BETA_FEATURES = ['discussion_iframe']

  class MaximumMembershipsExceeded < Exception
  end

  acts_as_tree

  DISCUSSION_PRIVACY_OPTIONS = ['public_only', 'private_only', 'public_or_private']
  MEMBERSHIP_GRANTED_UPON_OPTIONS = ['request', 'approval', 'invitation']

  validates_presence_of :name
  validates_inclusion_of :discussion_privacy_options, in: DISCUSSION_PRIVACY_OPTIONS
  validates_inclusion_of :membership_granted_upon, in: MEMBERSHIP_GRANTED_UPON_OPTIONS
  validates :name, length: { maximum: 250 }
  validates :subscription, absence: true, if: :is_subgroup?

  validate :limit_inheritance
  validate :validate_parent_members_can_see_discussions
  validate :validate_is_visible_to_parent_members
  validate :validate_discussion_privacy_options

  before_save :update_full_name_if_name_changed
  before_validation :set_discussions_private_only, if: :is_hidden_from_public?


  include PgSearch
  pg_search_scope :search_full_name, against: [:name, :description],
    using: {tsearch: {dictionary: "english"}}

  default_scope { includes(:default_group_cover) }

  scope :categorised_any, -> { where('groups.category_id IS NOT NULL') }
  scope :in_category, -> (category) { where(category_id: category.id) }

  scope :archived, lambda { where('archived_at IS NOT NULL') }
  scope :published, lambda { where(archived_at: nil) }

  scope :parents_only, -> { where(parent_id: nil) }

  scope :is_subscription, -> { where(is_commercial: true) }
  scope :is_donation, -> { where('is_commercial = false or is_commercial IS NULL') }

  scope :sort_by_popularity, -> { order('memberships_count DESC') }

  scope :visible_to_public, -> { published.where(is_visible_to_public: true) }
  scope :hidden_from_public, -> { published.where(is_visible_to_public: false) }
  scope :created_by, -> (user) { where(creator_id: user.id) }

  scope :visible_on_explore_front_page,
        -> { visible_to_public.categorised_any.parents_only.
             created_earlier_than(2.months.ago).
             active_discussions_since(1.month.ago).
             more_than_n_members(3).
             more_than_n_discussions(3).
             order('discussions.last_comment_at') }

  scope :include_admins, -> { includes(:admins) }

  scope :cannot_start_parent_group, -> { where(can_start_group: false) }

  # Engagement (Email Template) Related Scopes
  scope :more_than_n_members,     ->(count) { where('memberships_count > ?', count) }
  scope :less_than_n_members,     ->(count) { where('memberships_count < ?', count) }
  scope :more_than_n_discussions, ->(count) { where('discussions_count > ?', count) }
  scope :less_than_n_discussions, ->(count) { where('discussions_count < ?', count) }

  scope :no_active_discussions_since, ->(time) {
    includes(:discussions).where('(last_comment_at IS NULL and discussions.created_at < :time) OR
                                   last_comment_at < :time OR
                                   groups.discussions_count = 0', time: time).references(:discussions)
  }

  scope :active_discussions_since, ->(time) {
    includes(:discussions).where('discussions.last_comment_at > ?', time).references(:discussions)
  }

  scope :created_earlier_than, lambda {|time| where('groups.created_at < ?', time) }

  scope :engaged, -> { more_than_n_members(1).
                       more_than_n_discussions(2).
                       active_discussions_since(2.month.ago).
                       parents_only }

  scope :engaged_but_stopped, -> { more_than_n_members(1).
                                   more_than_n_discussions(2).
                                   no_active_discussions_since(2.month.ago).
                                   created_earlier_than(2.months.ago).
                                   parents_only }

  scope :has_members_but_never_engaged, -> { more_than_n_members(1).
                                             less_than_n_discussions(2).
                                             created_earlier_than(1.month.ago).
                                             parents_only }

  scope :alphabetically, -> { order('full_name asc') }
  scope :in_any_cohort, -> { where('cohort_id is not null') }

  has_one :group_request

  has_many :memberships,
           -> { where is_suspended: false, archived_at: nil },
           extend: GroupMemberships

  has_many :all_memberships,
           dependent: :destroy,
           class_name: 'Membership',
           extend: GroupMemberships

  has_many :membership_requests,
           dependent: :destroy

  has_many :pending_membership_requests,
           -> { where response: nil },
           class_name: 'MembershipRequest',
           dependent: :destroy

  has_many :admin_memberships,
           -> { where admin: true, archived_at: nil },
           class_name: 'Membership',
           dependent: :destroy

  has_many :members,
           through: :memberships,
           source: :user

  has_many :pending_invitations,
           -> { where accepted_at: nil, cancelled_at: nil },
           as: :invitable,
           class_name: 'Invitation'

  has_many :invitations,
           as: :invitable,
           class_name: 'Invitation',
           dependent: :destroy

  has_many :comments, through: :discussions

  after_initialize :set_defaults

  after_create :set_is_referral
  after_create :guess_cohort

  alias :users :members

  has_many :requested_users, through: :membership_requests, source: :user
  has_many :admins, through: :admin_memberships, source: :user
  has_many :discussions, dependent: :destroy
  has_many :motions, through: :discussions
  has_many :votes, through: :motions

  belongs_to :parent, class_name: 'Group'
  belongs_to :creator, class_name: 'User'
  belongs_to :category
  belongs_to :theme
  belongs_to :cohort
  belongs_to :default_group_cover

  has_many :subgroups,
           -> { where(archived_at: nil).order(:name) },
           class_name: 'Group',
           foreign_key: 'parent_id'

  has_many :comment_votes, through: :comments

  # maybe change this to just archived_subgroups
  has_many :all_subgroups,
           class_name: 'Group',
           foreign_key: :parent_id

  has_many :webhooks, as: :hookable

  belongs_to :subscription, dependent: :destroy

  delegate :include?, to: :users, prefix: true
  delegate :users, to: :parent, prefix: true
  delegate :members, to: :parent, prefix: true
  delegate :name, to: :parent, prefix: true
  delegate :locale, to: :creator

  paginates_per 20

  has_attached_file    :cover_photo,
                       styles: {largedesktop: "1400x320#", desktop: "970x200#", card: "460x94#"},
                       default_url: :default_cover_photo
  has_attached_file    :logo,
                       styles: { card: "67x67", medium: "100x100" },
                       default_url: 'default-logo-:style.png'

  validates_attachment :cover_photo,
    size: { in: 0..100.megabytes },
    content_type: { content_type: /\Aimage/ },
    file_name: { matches: [/png\Z/i, /jpe?g\Z/i, /gif\Z/i] }

  validates_attachment :logo,
    size: { in: 0..100.megabytes },
    content_type: { content_type: /\Aimage/ },
    file_name: { matches: [/png\Z/i, /jpe?g\Z/i, /gif\Z/i] }

  define_counter_cache(:motions_count)           { |group| group.discussions.published.sum(:motions_count) }
  define_counter_cache(:discussions_count)       { |group| group.discussions.published.count }
  define_counter_cache(:memberships_count)       { |group| group.memberships.count }
  define_counter_cache(:admin_memberships_count) { |group| group.admin_memberships.count }
  define_counter_cache(:invitations_count) { |group| group.invitations.count }

  # default_cover_photo is the name of the proc used to determine the url for the default cover photo
  # default_group_cover is the associated DefaultGroupCover object from which we get our default cover photo
  def default_cover_photo
    if is_subgroup?
      self.parent.default_cover_photo
    elsif self.default_group_cover
      /^.*(?=\?)/.match(self.default_group_cover.cover_photo.url).to_s
    else
      'img/default-cover-photo.png'
    end
  end

  before_save :set_creator_if_blank

  def set_creator_if_blank
    if self[:creator_id].blank? and admins.any?
      self.creator = admins.first
    end
  end

  alias_method :real_creator, :creator

  def creator
    self.real_creator || admins.first || members.first
  end

  def creator_id
    self[:creator_id] || creator.try(:id)
  end

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
    self.update_attribute(:archived_at, DateTime.now)
    memberships.update_all(archived_at: DateTime.now)
    subgroups.each do |group|
      group.archive!
    end
  end

  def is_archived?
    self.archived_at.present?
  end

  def unarchive!
    self.update_attribute(:archived_at, nil)
    all_memberships.update_all(archived_at: nil)
    all_subgroups.update_all(archived_at: nil)
  end

  def is_hidden_from_public?
    !is_visible_to_public?
  end

  def is_subgroup_of_hidden_parent?
    is_subgroup? and parent.is_hidden_from_public?
  end

  def group_privacy=(term)
    case term
    when 'open'
      self.is_visible_to_public = true
      self.discussion_privacy_options = 'public_only'

      unless %w[approval request].include?(self.membership_granted_upon)
        self.membership_granted_upon = 'approval'
      end
    when 'closed'
      self.is_visible_to_public = true
      self.membership_granted_upon = 'approval'
      unless %w[private_only public_or_private].include?(self.discussion_privacy_options)
        self.discussion_privacy_options = 'private_only'
      end

      # closed subgroup of hidden parent means parent members can seeee it!
      if is_subgroup_of_hidden_parent?
        self.is_visible_to_parent_members = true
        self.is_visible_to_public = false
      end
    when 'secret'
      self.is_visible_to_public = false
      self.discussion_privacy_options = 'private_only'
      self.membership_granted_upon = 'invitation'
      self.is_visible_to_parent_members = false
    else
      raise "group_privacy term not recognised: #{term}"
    end
  end

  def group_privacy
    if is_visible_to_public?
      self.public_discussions_only? ? 'open' : 'closed'
    elsif is_subgroup_of_hidden_parent? and is_visible_to_parent_members?
      'closed'
    else
      'secret'
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

  def org_members_count
    if is_subgroup?
      parent.org_members_count
    else
      Membership.active.where(group_id: [id, subgroups.pluck(:id)].flatten).pluck(:user_id).uniq.count
    end
  end

  def org_max_size
    if is_subgroup?
      parent.org_max_size
    else
      max_size
    end
  end

  def add_member!(user, inviter=nil)
    find_or_create_membership(user, inviter)
  end

  def add_members!(users, inviter=nil)
    users.map do |user|
      add_member!(user, inviter)
    end
  end

  def add_admin!(user, inviter = nil)
    membership = find_or_create_membership(user, inviter)
    membership.make_admin! && save
    self.creator = user if creator.blank?
    membership
  end

  def add_default_content!
    update default_group_cover: DefaultGroupCover.sample, subscription: Subscription.new_trial
    ExampleContent.add_to_group(self)
  end

  def find_or_create_membership(user, inviter)
    begin
      Membership.find_or_create_by(user_id: user.id, group_id: id) do |m|
        m.group = self
        m.user = user
        m.inviter = inviter
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end

  def has_member?(user)
    memberships.where(user_id: user.id).any?
  end

  def has_member_with_email?(email)
    members.where(email: email).any?
  end

  def has_membership_request_with_email?(email)
    membership_requests.where(email: email).any?
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

  def organisation_id
    parent_id or id
  end

  def organisation_discussions_count
    Group.where("parent_id = ? OR (parent_id IS NULL AND groups.id = ?)", parent_or_self.id, parent_or_self.id).sum(:discussions_count)
  end

  def organisation_motions_count
    Discussion.published.where(group_id: org_group_ids).sum(:motions_count)
  end

  def org_group_ids
    [parent_or_self.id, parent_or_self.subgroup_ids].flatten
  end

  def id_and_subgroup_ids
    Array(id) | subgroup_ids
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

  def financial_nature
    case is_commercial
    when nil then 'undefined'
    when false then 'non-commercial'
    when true then 'commercial'
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
    if is_visible_to_public?
      true
    else
      if parent_members_can_see_discussions?
        is_visible_to_parent_members?
      else
        true
      end
    end
  end

  def visible_to_parent_members_is_valid?
    if is_visible_to_public?
      true
    else
      if is_visible_to_parent_members?
        is_hidden_from_public? and is_subgroup?
      else
        true
      end
    end
  end

  def set_is_referral
    if creator && creator.groups.size > 0
      update_attribute(:is_referral, true)
    end
  end

  def set_defaults
    self.is_visible_to_public ||= false
    self.discussion_privacy_options ||= 'private_only'
    self.membership_granted_upon ||= 'approval'
  end

  def guess_cohort
    if self.cohort_id.blank?
      cohort_id = Group.where('cohort_id is not null').order('cohort_id desc').first.try(:cohort_id)
      self.update_attribute(:cohort_id, cohort_id) if cohort_id
    end
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

  def self.with_one_coordinator
    published.select{ |g| g.admins.count == 1 }
  end
end
