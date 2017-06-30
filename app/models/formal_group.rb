class FormalGroup < Group
  include HasTimeframe
  include MakesAnnouncements
  include MessageChannel

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

  scope :archived, -> { where('archived_at IS NOT NULL') }
  scope :published, -> { where(archived_at: nil) }

  scope :parents_only, -> { where(parent_id: nil) }

  scope :visible_to_public, -> { published.where(is_visible_to_public: true) }
  scope :hidden_from_public, -> { published.where(is_visible_to_public: false) }

  scope :explore_search, ->(query) { where("name ilike :q or description ilike :q", q: "%#{query}%") }

  after_initialize :set_defaults
  after_save   :associate_identity

  alias :users :members

  has_many :requested_users, through: :membership_requests, source: :user
  has_many :admins, through: :admin_memberships, source: :user
  has_many :comments, through: :discussions
  has_many :comment_votes, through: :comments
  has_many :motions, through: :discussions
  has_many :votes, through: :motions
  has_many :group_identities, dependent: :destroy, foreign_key: :group_id
  has_many :identities, through: :group_identities

  belongs_to :cohort
  belongs_to :default_group_cover

  has_many :subgroups,
           -> { where(archived_at: nil).order(:name) },
           class_name: 'Group',
           foreign_key: 'parent_id'
  has_many :all_subgroups, class_name: 'Group', foreign_key: :parent_id

  define_counter_cache(:motions_count)             { |group| group.discussions.published.sum(:motions_count) }
  define_counter_cache(:closed_motions_count)      { |group| group.motions.closed.count }
  define_counter_cache(:proposal_outcomes_count)   { |group| group.motions.with_outcomes.count }

  delegate :include?, to: :users, prefix: true
  delegate :users, to: :parent, prefix: true
  delegate :members, to: :parent, prefix: true
  delegate :name, to: :parent, prefix: true

  delegate :slack_team_id, to: :slack_identity, allow_nil: true
  delegate :slack_channel_id, to: :slack_identity, allow_nil: true
  delegate :slack_team_name, to: :slack_identity, allow_nil: true
  delegate :slack_channel_name, to: :slack_identity, allow_nil: true

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

  validates :description, length: { maximum: Rails.application.secrets.max_message_length }

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
      if is_formal_group? && is_subgroup_of_hidden_parent?
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
    elsif is_formal_group? && is_subgroup_of_hidden_parent? && is_visible_to_parent_members?
      'closed'
    else
      'secret'
    end
  end

  def shareable_invitation
    invitations.find_or_create_by(
      single_use:     false,
      intent:         :join_group,
      group:      self
    )
  end

  def logo_or_parent_logo
    if is_parent?
      logo
    else
      logo.presence || parent.logo
    end
  end

  # attr_writer :identity_id
  # def identity_id
  #   @identity_id || community.identity_id
  # end

  def identity_id=(id)
    self.group_identities.build(identity_id: id)
  end

  def associate_identity
    # community.update(identity_id: self.identity_id) if self.identity_id
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


  def discussion_private_default
    case discussion_privacy_options
    when 'public_or_private' then nil
    when 'public_only' then false
    when 'private_only' then true
    else
      raise "invalid discussion_privacy value"
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

  def slack_identity
    identity_for(:slack)
  end

  def identity_for(type)
    group_identities.joins(:identity).find_by("omniauth_identities.identity_type": type)
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
