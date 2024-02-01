class Discussion < ApplicationRecord
  include CustomCounterCache::Model
  include ReadableUnguessableUrls
  include Translatable
  include Reactable
  include HasTimeframe
  include HasEvents
  include HasMentions
  include MessageChannel
  include SelfReferencing
  include HasCreatedEvent
  include HasRichText
  include HasTags
  extend  NoSpam
  include Discard::Model

  include Searchable

  def self.pg_search_insert_statement(id: nil, author_id: nil)
    content_str = "regexp_replace(CONCAT_WS(' ', discussions.title, discussions.description, users.name), E'<[^>]+>', '', 'gi')"
    <<~SQL.squish
      INSERT INTO pg_search_documents (
        searchable_type,
        searchable_id,
        group_id,
        discussion_id,
        author_id,
        authored_at,
        content,
        ts_content,
        created_at,
        updated_at)
      SELECT 'Discussion' AS searchable_type,
        discussions.id AS searchable_id,
        discussions.group_id as group_id,
        discussions.id AS discussion_id,
        discussions.author_id AS author_id,
        discussions.created_at AS authored_at,
        #{content_str} AS content,
        to_tsvector('simple', #{content_str}) as ts_content,
        now() AS created_at,
        now() AS updated_at
      FROM discussions
        LEFT JOIN users ON users.id = discussions.author_id
      WHERE discarded_at IS NULL
        #{id ? " AND discussions.id = #{id.to_i} LIMIT 1" : ""}
        #{author_id ? " AND discussions.author_id = #{author_id.to_i}" : ""}
    SQL
  end

  no_spam_for :title, :description

  scope :dangling, -> { joins('left join groups g on discussions.group_id = g.id').where('group_id is not null and g.id is null') }
  scope :in_organisation, -> (group) { includes(:author).where(group_id: group.id_and_subgroup_ids) }
  scope :last_activity_after, -> (time) { where('last_activity_at > ?', time) }
  scope :order_by_latest_activity, -> { order(last_activity_at: :desc) }
  scope :recent, -> { where('last_activity_at > ?', 6.weeks.ago) }

  scope :visible_to_public, -> { kept.where(private: false) }
  scope :not_visible_to_public, -> { kept.where(private: true) }

  scope :is_open, -> { kept.where(closed_at: nil) }
  scope :is_closed, -> { kept.where("closed_at is not null") }

  validates_presence_of :title, :group, :author
  validates :title, length: { maximum: 150 }
  validates :description, length: { maximum: Rails.application.secrets.max_message_length }
  validate :privacy_is_permitted_by_group

  is_mentionable  on: :description
  is_translatable on: [:title, :description], load_via: :find_by_key!, id_field: :key
  is_rich_text    on: :description
  has_paper_trail only: [:title, :description, :description_format, :private, :group_id, :author_id, :tags, :closed_at, :closer_id]

  belongs_to :group, class_name: 'Group'
  belongs_to :author, class_name: 'User'
  belongs_to :user, foreign_key: 'author_id'
  belongs_to :closer, foreign_key: 'closer_id', class_name: "User"
  has_many :polls, dependent: :destroy
  has_many :active_polls, -> { where(closed_at: nil) }, class_name: "Poll"

  has_many :comments, dependent: :destroy
  has_many :commenters, -> { uniq }, through: :comments, source: :user
  has_many :documents, as: :model, dependent: :destroy
  has_many :poll_documents,    through: :polls,    source: :documents
  has_many :comment_documents, through: :comments, source: :documents

  has_many :items, -> { includes(:user) }, class_name: 'Event', dependent: :destroy

  has_many :discussion_readers, dependent: :destroy
  has_many :readers,-> { merge DiscussionReader.active },  through: :discussion_readers, source: :user
  has_many :guests, -> { merge DiscussionReader.guests }, through: :discussion_readers, source: :user
  has_many :admin_guests, -> { merge DiscussionReader.admins }, through: :discussion_readers, source: :user
  include DiscussionExportRelations

  scope :search_for, -> (q) do
    kept.where("discussions.title ilike ?", "%#{q}%")
  end

  delegate :name, to: :group, prefix: :group
  delegate :name, to: :author, prefix: :author
  delegate :users, to: :group, prefix: :group
  delegate :full_name, to: :group, prefix: :group
  delegate :email, to: :author, prefix: :author
  delegate :name_and_email, to: :author, prefix: :author
  delegate :locale, to: :author

  after_create :set_last_activity_at_to_created_at
  after_destroy :drop_sequence_id_sequence

  define_counter_cache(:closed_polls_count)         { |d| d.polls.closed.count }
  define_counter_cache(:versions_count)             { |d| d.versions.count }
  define_counter_cache(:seen_by_count)              { |d| d.discussion_readers.where("last_read_at is not null").count }
  define_counter_cache(:members_count)              { |d| d.discussion_readers.where("revoked_at is null").count }
  define_counter_cache(:anonymous_polls_count)      { |d| d.polls.where(anonymous: true).count }

  update_counter_cache :group, :discussions_count
  update_counter_cache :group, :public_discussions_count
  update_counter_cache :group, :open_discussions_count
  update_counter_cache :group, :closed_discussions_count
  update_counter_cache :group, :closed_polls_count

  def poll
    nil
  end
  
  def group
    super || NullGroup.new
  end

  def existing_member_ids
    reader_ids
  end

  def user_id
    author_id
  end

  def author
    super || AnonymousUser.new
  end

  def members
    User.active.
      joins("LEFT OUTER JOIN discussion_readers dr ON dr.discussion_id = #{self.id || 0} AND dr.user_id = users.id").
      joins("LEFT OUTER JOIN memberships m ON m.user_id = users.id AND m.group_id = #{self.group_id || 0}").
      where('(m.id IS NOT NULL AND m.revoked_at IS NULL) OR
             (dr.id IS NOT NULL AND dr.guest = TRUE AND dr.revoked_at IS NULL)')
  end

  def admins
    User.active.
      joins("LEFT OUTER JOIN discussion_readers dr ON dr.discussion_id = #{self.id || 0} AND dr.user_id = users.id").
      joins("LEFT OUTER JOIN memberships m ON m.user_id = users.id AND m.group_id = #{self.group_id || 0}").
      where('(m.admin = TRUE AND m.id IS NOT NULL AND m.revoked_at IS NULL) OR
             (dr.admin = TRUE AND dr.id IS NOT NULL AND dr.revoked_at IS NULL)')
  end

  def guests
    members.where('m.group_id is null')
  end

  def add_guest!(user, inviter)
    if dr = discussion_readers.find_by(user: user)
      dr.update(guest: true, inviter: inviter)
    else
      discussion_readers.create!(user: user, inviter: inviter, guest: true, volume: DiscussionReader.volumes[:normal])
    end
  end

  def add_admin!(user, inviter)
    if dr = discussion_readers.find_by(user: user)
      dr.update(inviter: inviter, admin: true)
    else
      discussion_readers.create!(user: user, inviter: inviter, admin: true, volume: DiscussionReader.volumes[:normal])
    end
  end

  def poll_id
    nil
  end

  def created_event_kind
    :new_discussion
  end

  def update_sequence_info!
    sequence_ids = discussion.items.order(:sequence_id).pluck(:sequence_id).compact
    discussion.ranges_string = RangeSet.serialize RangeSet.reduce RangeSet.ranges_from_list sequence_ids
    discussion.last_activity_at = discussion.items.unreadable.order(:sequence_id).last&.created_at || created_at
    update_columns(
      items_count: sequence_ids.count,
      ranges_string: discussion.ranges_string,
      last_activity_at: discussion.last_activity_at)
  end

  def drop_sequence_id_sequence
    SequenceService.drop_seq!('discussions_sequence_id', id)
  end

  def public?
    !private
  end

  def discussion
    self
  end

  def body=(val)
    self.description=(val)
  end

  def body
    self.description
  end

  def body_format
    self.description_format
  end

  def body_format=(val)
    self.description_format=(val)
  end

  def ranges
    RangeSet.parse(self.ranges_string)
  end

  def first_sequence_id
    Array(ranges.first).first.to_i
  end

  def last_sequence_id
    Array(ranges.last).last.to_i
  end

  # this is insted of a big slow migration
  def ranges_string
    update_sequence_info! if self[:ranges_string].nil?
    self[:ranges_string]
  end

  def is_new_version?
    (['title', 'description', 'private'] & self.changes.keys).any?
  end

  private

  def set_last_activity_at_to_created_at
    update_column(:last_activity_at, created_at)
  end

  def sequence_id_or_0(item)
    item.try(:sequence_id) || 0
  end

  def privacy_is_permitted_by_group
    if self.public? and group.private_discussions_only?
      errors.add(:private, "must be private")
    end

    if self.private? and group.public_discussions_only?
      errors.add(:private, "must be public")
    end
  end
end
