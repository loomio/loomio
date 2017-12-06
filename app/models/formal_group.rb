class FormalGroup < Group
  include HasTimeframe
  include MakesAnnouncements

  validates_presence_of :name
  validates :name, length: { maximum: 250 }

  validate :limit_inheritance

  before_save :update_full_name_if_name_changed

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

  has_many :requested_users, through: :membership_requests, source: :user
  has_many :comments, through: :discussions
  has_many :motions, through: :discussions
  has_many :votes, through: :motions
  has_many :group_identities, dependent: :destroy, foreign_key: :group_id
  has_many :identities, through: :group_identities
  has_many :documents, as: :model
  has_many :discussion_documents, through: :discussions, source: :documents
  has_many :poll_documents,       through: :polls,       source: :documents
  has_many :comment_documents,    through: :comments,    source: :documents

  belongs_to :cohort
  belongs_to :default_group_cover

  has_many :subgroups,
           -> { where(archived_at: nil).order(:name) },
           class_name: 'Group',
           foreign_key: 'parent_id'
  has_many :all_subgroups, class_name: 'Group', foreign_key: :parent_id

  define_counter_cache(:public_discussions_count)  { |group| group.discussions.visible_to_public.count }
  define_counter_cache(:discussions_count)         { |group| group.discussions.published.count }
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
                       default_url: AppConfig.theme[:default_group_logo_src]

  validates_attachment :cover_photo,
    size: { in: 0..100.megabytes },
    content_type: { content_type: /\Aimage/ },
    file_name: { matches: [/png\Z/i, /jpe?g\Z/i, /gif\Z/i] }

  validates_attachment :logo,
    size: { in: 0..100.megabytes },
    content_type: { content_type: /\Aimage/ },
    file_name: { matches: [/png\Z/i, /jpe?g\Z/i, /gif\Z/i] }

  validates :description, length: { maximum: Rails.application.secrets.max_message_length }

  def update_undecided_user_count
    # NOOP: only guest groups have an invitation target
  end

  def shareable_invitation
    invitations.find_or_create_by(
      single_use: false,
      intent:     :join_group,
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

  def calculate_full_name
    [parent&.name, name].compact.join(" - ")
  end

  def limit_inheritance
    if parent_id.present?
      errors[:base] << "Can't set a subgroup as parent" unless parent.parent_id.nil?
    end
  end
end
