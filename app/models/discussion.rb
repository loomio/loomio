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
        topics.group_id as group_id,
        discussions.id AS discussion_id,
        discussions.author_id AS author_id,
        discussions.created_at AS authored_at,
        #{content_str} AS content,
        to_tsvector('simple', #{content_str}) as ts_content,
        now() AS created_at,
        now() AS updated_at
      FROM discussions
        LEFT JOIN topics ON topics.id = discussions.topic_id
        LEFT JOIN users ON users.id = discussions.author_id
      WHERE discarded_at IS NULL
        #{id ? " AND discussions.id = #{id.to_i} LIMIT 1" : ''}
        #{author_id ? " AND discussions.author_id = #{author_id.to_i}" : ''}
    SQL
  end

  scope :dangling, lambda {
    joins(:topic).joins('left join groups g on topics.group_id = g.id').where('topics.group_id is not null and g.id is null')
  }
  scope :in_organisation, ->(group) { includes(:author).joins(:topic).where(topics: { group_id: group.id_and_subgroup_ids }) }
  scope :last_activity_after, ->(time) { joins(:topic).where('topics.last_activity_at > ?', time) }
  scope :order_by_latest_activity, -> { joins(:topic).order('topics.last_activity_at DESC') }
  scope :order_by_pinned_then_latest_activity, -> { joins(:topic).order('topics.pinned_at, topics.last_activity_at DESC') }
  scope :recent, -> { joins(:topic).where('topics.last_activity_at > ?', 6.weeks.ago) }

  scope :visible_to_public, -> { kept.joins(:topic).where(topics: { private: false }) }
  scope :not_visible_to_public, -> { kept.joins(:topic).where(topics: { private: true }) }

  scope :is_open, -> { kept.joins(:topic).where('topics.closed_at IS NULL') }
  scope :is_closed, -> { kept.joins(:topic).where('topics.closed_at IS NOT NULL') }

  validates_presence_of :title, :author
  validates :title, length: { maximum: 150 }
  validates :description, length: { maximum: AppConfig.app_features[:max_message_length] }

  is_mentionable  on: :description
  is_translatable on: %i[title description], load_via: :find_by_key!, id_field: :key
  is_rich_text    on: :description
  has_paper_trail only: %i[title description description_format author_id tags attachments]

  belongs_to :topic, autosave: true
  belongs_to :author, class_name: 'User'
  belongs_to :user, foreign_key: 'author_id'

  has_many :polls, primary_key: :topic_id, foreign_key: :topic_id, dependent: :destroy
  has_many :active_polls, -> { where(closed_at: nil) }, class_name: 'Poll', primary_key: :topic_id, foreign_key: :topic_id

  has_many :topic_readers, through: :topic
  has_many :readers, -> { merge TopicReader.active }, through: :topic_readers, source: :user

  has_many :comments, through: :topic
  has_many :comment_documents, through: :comments, source: :documents

  has_many :commenters, -> { uniq }, through: :comments, source: :user
  has_many :documents, as: :model, dependent: :destroy
  has_many :poll_documents,    through: :polls,    source: :documents

  include DiscussionExportRelations

  scope :search_for, lambda { |q|
    kept.where('discussions.title ilike ?', "%#{q}%")
  }

  delegate :name, to: :group, prefix: :group
  delegate :name, to: :author, prefix: :author
  delegate :users, to: :group, prefix: :group
  delegate :full_name, to: :group, prefix: :group
  delegate :email, to: :author, prefix: :author
  delegate :name_and_email, to: :author, prefix: :author
  delegate :locale, to: :author
  delegate :members, :admins, :guests, :guest_ids, :add_guest!, :add_admin!, to: :topic

  define_counter_cache(:versions_count)             { |d| d.versions.count }

  after_commit :update_group_counter_caches

  def update_group_counter_caches
    #TODO can this be a background job or materialized view
    return unless (g = topic.group) && g.id
    g.update_discussions_count
    # g.update_public_discussions_count
    g.update_open_discussions_count
    g.update_closed_discussions_count
    g.update_closed_polls_count
  end

  def title_model
    self
  end

  def user_id
    author_id
  end

  def created_event_kind
    :new_discussion
  end

  def body=(val)
    self.description = (val)
  end

  def body
    description
  end

  def body_format
    description_format
  end

  def body_format=(val)
    self.description_format = (val)
  end

  def is_new_version?
    (%w[title description] & changes.keys).any? || topic&.private_changed?
  end

end
