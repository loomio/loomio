class Group < ActiveRecord::Base
  include ReadableUnguessableUrls
  include HasTimeframe
  include HasPolls
  include MessageChannel

  class MaximumMembershipsExceeded < Exception
  end

  DISCUSSION_PRIVACY_OPTIONS = ['public_only', 'private_only', 'public_or_private']
  MEMBERSHIP_GRANTED_UPON_OPTIONS = ['request', 'approval', 'invitation']

  validates_presence_of :name
  validates_inclusion_of :discussion_privacy_options, in: DISCUSSION_PRIVACY_OPTIONS
  validates_inclusion_of :membership_granted_upon, in: MEMBERSHIP_GRANTED_UPON_OPTIONS
  validates :name, length: { maximum: 250 }

  validate :limit_inheritance
  validate :validate_parent_members_can_see_discussions
  validate :validate_is_visible_to_parent_members
  validate :validate_discussion_privacy_options

  before_save :update_full_name_if_name_changed
  before_validation :set_discussions_private_only, if: :is_hidden_from_public?

  default_scope { includes(:default_group_cover) }

  scope :categorised_any, -> { where('groups.category_id IS NOT NULL') }
  scope :in_category, -> (category) { where(category_id: category.id) }

  scope :archived, lambda { where('archived_at IS NOT NULL') }
  scope :published, lambda { where(archived_at: nil) }

  scope :parents_only, -> { where(parent_id: nil) }

  scope :sort_by_popularity, -> { order('memberships_count DESC') }

  scope :visible_to_public, -> { published.where(is_visible_to_public: true) }
  scope :hidden_from_public, -> { published.where(is_visible_to_public: false) }

  scope :explore_search, ->(query) { where("name ilike :q or description ilike :q", q: "%#{query}%") }

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
    includes(:discussions).where('discussions.last_activity_at > ?', time).references(:discussions)
  }

  scope :created_earlier_than, lambda {|time| where('groups.created_at < ?', time) }

  scope :engaged, ->(since = 2.months.ago) {
    more_than_n_members(1).
    more_than_n_discussions(2).
    active_discussions_since(since)
  }

  scope :with_analytics, ->(since = 1.month.ago) {
    where(analytics_enabled: true).engaged(since).joins(:admin_memberships)
  }

  scope :engaged_but_stopped, -> { more_than_n_members(1).
                                   more_than_n_discussions(2).
                                   no_active_discussions_since(2.month.ago).
                                   created_earlier_than(2.months.ago).
                                   parents_only }

  scope :has_members_but_never_engaged, -> { more_than_n_members(1).
                                             less_than_n_discussions(2).
                                             created_earlier_than(1.month.ago).
                                             parents_only }

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

  after_create :guess_cohort

  alias :users :members

  has_many :requested_users, through: :membership_requests, source: :user
  has_many :admins, through: :admin_memberships, source: :user
  has_many :discussions, dependent: :destroy
  has_many :motions, through: :discussions
  has_many :polls, through: :discussions
  has_many :votes, through: :motions

  belongs_to :parent, class_name: 'Group'
  belongs_to :creator, class_name: 'User'
  belongs_to :category
  belongs_to :theme
  belongs_to :cohort
  belongs_to :community, class_name: 'Communities::LoomioGroup'
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

  delegate :include?, to: :users, prefix: true
  delegate :users, to: :parent, prefix: true
  delegate :members, to: :parent, prefix: true
  delegate :name, to: :parent, prefix: true

  paginates_per 20

  has_attached_file    :cover_photo,
                       styles: {largedesktop: "1400x320#", desktop: "970x200#", card: "460x94#"},
                       default_url: :default_cover_photo
  has_attached_file    :logo,
                       styles: { card: "67x67#", medium: "100x100#" },
                       default_url: 'default-logo-:style.png'

  validates_attachment :cover_photo,
    size: { in: 0..100.megabytes },
    content_type: { content_type: /\Aimage/ },
    file_name: { matches: [/png\Z/i, /jpe?g\Z/i, /gif\Z/i] }

  validates_attachment :logo,
    size: { in: 0..100.megabytes },
    content_type: { content_type: /\Aimage/ },
    file_name: { matches: [/png\Z/i, /jpe?g\Z/i, /gif\Z/i] }

  define_counter_cache(:motions_count)             { |group| group.discussions.published.sum(:motions_count) }
  define_counter_cache(:closed_motions_count)      { |group| group.motions.closed.count }
  define_counter_cache(:closed_polls_count)        { |group| group.polls.closed.count }
  define_counter_cache(:discussions_count)         { |group| group.discussions.published.count }
  define_counter_cache(:public_discussions_count)  { |group| group.discussions.visible_to_public.count }
  define_counter_cache(:memberships_count)         { |group| group.memberships.count }
  define_counter_cache(:admin_memberships_count)   { |group| group.admin_memberships.count }
  define_counter_cache(:invitations_count)         { |group| group.invitations.count }
  define_counter_cache(:proposal_outcomes_count)   { |group| group.motions.with_outcomes.count }
  define_counter_cache(:pending_invitations_count) { |group| group.invitations.pending.count }
  define_counter_cache(:announcement_recipients_count) { |group| group.memberships.volume_at_least(:normal).count }

  def group
    self
  end

  def community
    update(community: Communities::LoomioGroup.create(group: self)) unless self[:community_id]
    super
  end

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

  def requestor_name
    group_request.try(:admin_name)
  end

  def requestor_email
    group_request.try(:admin_email)
  end

  def archive!
    self.update_attribute(:archived_at, DateTime.now)
    memberships.update_all(archived_at: DateTime.now)
    subgroups.map(&:archive!)
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

  # this method's a bit chunky. New class?
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
    memberships.find_by(user_id: user.id)
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
    begin
      tap(&:save!).memberships.find_or_create_by(user: user) { |m| m.inviter = inviter }
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end

  def add_members!(users, inviter=nil)
    users.map { |user| add_member!(user, inviter) }
  end

  def add_admin!(user, inviter = nil)
    add_member!(user, inviter).tap do |m|
      m.make_admin!
      update(creator: user) if creator.blank?
      reload
    end
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

  def parent_or_self
    parent || self
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

  def set_defaults
    self.is_visible_to_public ||= false
    self.discussion_privacy_options ||= 'private_only'
    self.membership_granted_upon ||= 'approval'
    self.features['use_polls'] = true
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
end
