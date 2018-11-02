class FormalGroup < Group
  include HasTimeframe
  include HasDrafts

  extend  NoSpam
  no_spam_for :name, :description

  validates_presence_of :name
  validates :name, length: { maximum: 250 }

  validate :limit_inheritance

  scope :parents_only, -> { where(parent_id: nil) }
  scope :visible_to_public, -> { published.where(is_visible_to_public: true) }
  scope :hidden_from_public, -> { published.where(is_visible_to_public: false) }
  scope :in_organisation, ->(group) { where(id: group.id_and_subgroup_ids) }

  scope :explore_search, ->(query) { where("name ilike :q or description ilike :q", q: "%#{query}%") }

  scope :by_slack_team, ->(team_id) {
     joins(:identities)
    .where("(omniauth_identities.custom_fields->'slack_team_id')::jsonb ? :team_id", team_id: team_id)
  }

  scope :by_slack_channel, ->(channel_id) {
     joins(:group_identities)
    .where("(group_identities.custom_fields->'slack_channel_id')::jsonb ? :channel_id", channel_id: channel_id)
  }

  scope :search_for, ->(query) { where("name ilike :q", q: "%#{query}%") }

  has_many :requested_users, through: :membership_requests, source: :user
  has_many :comments, through: :discussions
  has_many :public_comments, through: :public_discussions, source: :comments

  has_many :group_identities, dependent: :destroy, foreign_key: :group_id
  has_many :identities, through: :group_identities

  has_many :discussion_documents,        through: :discussions,        source: :documents
  has_many :poll_documents,              through: :polls,              source: :documents
  has_many :comment_documents,           through: :comments,           source: :documents
  has_many :public_discussion_documents, through: :public_discussions, source: :documents
  has_many :public_poll_documents,       through: :public_polls,       source: :documents
  has_many :public_comment_documents,    through: :public_comments,    source: :documents

  belongs_to :cohort
  belongs_to :default_group_cover

  has_many :subgroups,
           -> { where(archived_at: nil) },
           class_name: 'Group',
           foreign_key: 'parent_id'
  has_many :all_subgroups, class_name: 'Group', foreign_key: :parent_id

  define_counter_cache(:public_discussions_count)  { |group| group.discussions.visible_to_public.count }
  define_counter_cache(:discussions_count)         { |group| group.discussions.count }
  define_counter_cache(:open_discussions_count)    { |group| group.discussions.is_open.count }
  define_counter_cache(:closed_discussions_count)  { |group| group.discussions.is_closed.count }
  define_counter_cache(:discussions_count)         { |group| group.discussions.count }
  define_counter_cache(:subgroups_count)           { |group| group.subgroups.published.count }

  delegate :include?, to: :users, prefix: true
  delegate :members, to: :parent, prefix: true

  delegate :slack_team_id, to: :slack_identity, allow_nil: true
  delegate :slack_channel_id, to: :slack_identity, allow_nil: true
  delegate :slack_team_name, to: :slack_identity, allow_nil: true
  delegate :slack_channel_name, to: :slack_identity, allow_nil: true

  has_attached_file    :cover_photo,
                       url: "/system/groups/:attachment/:id_partition/:style/:filename",
                       styles: {largedesktop: "1400x320#", desktop: "970x200#", card: "460x94#"},
                       default_url: :default_cover_photo
  has_attached_file    :logo,
                       url: "/system/groups/:attachment/:id_partition/:style/:filename",
                       styles: { card: "67x67#", medium: "100x100#" },
                       default_url: AppConfig.theme[:icon_src]

  validates_attachment :cover_photo,
    size: { in: 0..100.megabytes },
    content_type: { content_type: /\Aimage/ },
    file_name: { matches: [/png\Z/i, /jpe?g\Z/i, /gif\Z/i] }

  validates_attachment :logo,
    size: { in: 0..100.megabytes },
    content_type: { content_type: /\Aimage/ },
    file_name: { matches: [/png\Z/i, /jpe?g\Z/i, /gif\Z/i] }

  validates :description, length: { maximum: Rails.application.secrets.max_message_length }

  alias_method :draft_parent, :parent

  def update_undecided_count
    polls.active.each(&:update_undecided_count)
  end

  def logo_or_parent_logo
    if is_parent?
      logo
    else
      logo.presence || parent.logo
    end
  end

  # default_cover_photo is the name of the proc used to determine the url for the default cover photo
  # default_group_cover is the associated DefaultGroupCover object from which we get our default cover photo
  def default_cover_photo
    if is_subgroup?
      self.parent.default_cover_photo
    elsif self.default_group_cover
      /^.*(?=\?)/.match(self.default_group_cover.cover_photo.url).to_s
    else
      AppConfig.theme[:default_group_cover_src]
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

  def full_name
    if is_subgroup?
      [parent.name, name].join(' - ')
    else
      name
    end
  end

  def id_and_subgroup_ids
    Array(id) | subgroup_ids
  end

  def handle
    if is_subgroup?
      parent.handle
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

  def limit_inheritance
    if parent_id.present?
      errors[:base] << "Can't set a subgroup as parent" unless parent.parent_id.nil?
    end
  end
end
