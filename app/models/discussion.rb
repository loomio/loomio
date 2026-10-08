class Discussion < ApplicationRecord
  include HasVersionsCount
  include ReadableUnguessableUrls
  include Translatable
  include Reactable
  include Bookmarkable
  include HasTimeframe
  include HasTopicItems
  include HasNotifications
  include HasMentions
  include SelfReferencing
  include HasRichText
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
        topic_id,
        tags,
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
        discussions.topic_id AS topic_id,
        topics.tags AS tags,
        discussions.author_id AS author_id,
        discussions.created_at AS authored_at,
        #{content_str} AS content,
        to_tsvector('simple', #{content_str}) as ts_content,
        now() AS created_at,
        now() AS updated_at
      FROM discussions
        LEFT JOIN topics ON topics.id = discussions.topic_id
        LEFT JOIN users ON users.id = discussions.author_id
      WHERE discussions.discarded_at IS NULL
        #{id ? " AND discussions.id = #{id.to_i} LIMIT 1" : ''}
        #{author_id ? " AND discussions.author_id = #{author_id.to_i}" : ''}
    SQL
  end

  scope :last_activity_after, ->(time) { joins(:topic).where('topics.last_activity_at > ?', time) }
  scope :order_by_latest_activity, -> { joins(:topic).order('topics.last_activity_at DESC') }
  scope :order_by_pinned_then_latest_activity, -> { joins(:topic).order('topics.pinned_at, topics.last_activity_at DESC') }
  scope :recent, -> { joins(:topic).where('topics.last_activity_at > ?', 6.weeks.ago) }

  scope :visible_to_public, -> { kept.joins(:topic).where(topics: { private: false }) }
  scope :not_visible_to_public, -> { kept.joins(:topic).where(topics: { private: true }) }

  scope :is_unlocked, -> { kept.joins(:topic).where('topics.locked_at IS NULL') }
  scope :is_locked, -> { kept.joins(:topic).where('topics.locked_at IS NOT NULL') }

  validates_presence_of :title, :author
  validates :title, length: { maximum: 150 }
  validates :description, length: { maximum: AppConfig.app_features[:max_message_length] }

  is_mentionable  on: :description
  is_translatable on: %i[title description], load_via: :find_by_key!, id_field: :key
  is_rich_text    on: :description
  has_paper_trail only: %i[title description description_format author_id tags attachments]

  belongs_to :topic
  belongs_to :author, class_name: 'User'
  belongs_to :user, foreign_key: 'author_id'
  belongs_to :discussion_template, optional: true

  has_many :polls, primary_key: :topic_id, foreign_key: :topic_id, dependent: :destroy
  has_many :active_polls, -> { where(closed_at: nil) }, class_name: 'Poll', primary_key: :topic_id, foreign_key: :topic_id

  has_many :topic_readers, through: :topic
  has_many :readers, -> { merge TopicReader.active }, through: :topic_readers, source: :user

  # TODO remove these 3 associations if we can.
  has_many :comments, through: :topic
  has_many :comment_documents, through: :comments, source: :documents
  has_many :commenters, -> { uniq }, through: :comments, source: :user
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
  delegate :members, :admins, :guests, :guest_ids, :add_guest!, :add_admin!, :group_id, :group,
           :seen_by_count, :anonymous_polls_count,
           :items, :newest_first, :private, :pinned_at,
           :last_activity_at, :items_count, :ranges, to: :topic

  after_create :add_group_discussion_count
  after_update :change_group_discussion_count, if: -> { saved_change_to_topic_id? || saved_change_to_discarded_at? }
  after_destroy :remove_group_discussion_count
  before_create :lock_topics_for_counts
  before_update :lock_topics_for_counts, if: -> { changes.keys.intersect?(%w[topic_id discarded_at]) }
  before_destroy :lock_topics_for_counts

  def lock_topics_for_counts
    ids = [topic_id, topic_id_in_database].compact.uniq
    @count_group_ids = Topic.where(id: ids).order(:id).lock('FOR NO KEY UPDATE').pluck(:id, :group_id).to_h
  end

  def add_group_discussion_count
    current_group_id = topic_id ? @count_group_ids.fetch(topic_id) : group_id
    RecordCountService.transfer!(Group, :discussions_count, from: nil, to: kept? ? current_group_id : nil, records: [group])
  end

  def change_group_discussion_count
    # Autosaving the mutually referencing discussion/topic pair links the
    # topic ID in a second save. Creation already counted its loaded group.
    previous_group_id = topic_id_before_last_save ? @count_group_ids.fetch(topic_id_before_last_save) : group_id
    RecordCountService.transfer!(Group, :discussions_count,
      from: discarded_at_before_last_save.nil? ? previous_group_id : nil,
      to: kept? ? @count_group_ids.fetch(topic_id) : nil, records: [group])
  end

  def remove_group_discussion_count
    RecordCountService.transfer!(Group, :discussions_count, from: kept? ? @count_group_ids.fetch(topic_id) : nil, to: nil, records: [group])
  end
  private :lock_topics_for_counts, :add_group_discussion_count, :change_group_discussion_count, :remove_group_discussion_count

  def author
    super || LoggedOutUser.new(name: I18n.t('profile_page.deleted_account'))
  end

  def title_model
    self
  end

  def user_id
    author_id
  end

  def created_topic_item_kind
    :new_discussion
  end

  def created_from_group_template?
    discussion_template&.kept? && !discussion_template.hidden? && discussion_template.group_id == group_id
  end

  def tag_names_not_from_template
    TagService.clean_tag_names(topic.tags) - TagService.clean_tag_names(discussion_template&.tags)
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
