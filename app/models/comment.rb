class Comment < ApplicationRecord
  include Discard::Model
  include CustomCounterCache::Model
  include Translatable
  include Reactable
  include HasMentions
  include HasCreatedEvent
  include HasEvents
  include HasRichText
  include Searchable

  def self.pg_search_insert_statement(id: nil, author_id: nil, topic_id: nil)
    content_str = "regexp_replace(CONCAT_WS(' ', comments.body, users.name), E'<[^>]+>', '', 'gi')"
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
      SELECT 'Comment' AS searchable_type,
        comments.id AS searchable_id,
        topics.group_id as group_id,
        CASE WHEN topics.topicable_type = 'Discussion' THEN topics.topicable_id ELSE NULL END AS discussion_id,
        comments.user_id AS author_id,
        comments.created_at AS authored_at,
        #{content_str} AS content,
        to_tsvector('simple',#{content_str}) as ts_content,
        now() AS created_at,
        now() AS updated_at
      FROM comments
        LEFT JOIN events ON events.eventable_type = 'Comment' AND events.eventable_id = comments.id
        LEFT JOIN topics ON topics.id = events.topic_id
        LEFT JOIN users ON users.id = comments.user_id
      WHERE comments.discarded_at IS NULL
        #{id ? " AND comments.id = #{id.to_i} LIMIT 1" : ""}
        #{author_id ? " AND comments.user_id = #{author_id.to_i}" : ""}
        #{topic_id ? " AND events.topic_id = #{topic_id.to_i}" : ""}
    SQL
  end

  has_paper_trail only: [:body, :body_format, :user_id, :discarded_at, :discarded_by, :attachments]

  is_translatable on: :body
  is_mentionable  on: :body
  is_rich_text    on: :body

  belongs_to :user
  belongs_to :parent, polymorphic: true

  has_many :documents, as: :model, dependent: :destroy

  validates_presence_of :user, unless: :discarded_at

  validate :parent_belongs_to_same_topic
  validate :has_body_or_attachment

  alias_method :author, :user
  alias_method :author=, :user=

  scope :dangling, -> {
    joins("LEFT JOIN events ON events.eventable_type = 'Comment' AND events.eventable_id = comments.id")
    .joins("LEFT JOIN topics ON topics.id = events.topic_id")
    .where("events.id IS NULL OR topics.id IS NULL")
  }
  scope :in_organisation, ->(group) {
    includes(:user)
    .joins("INNER JOIN events ON events.eventable_type = 'Comment' AND events.eventable_id = comments.id")
    .joins("INNER JOIN topics ON topics.id = events.topic_id")
    .where("topics.group_id IN (?)", group.id_and_subgroup_ids)
  }

  delegate :name, to: :user, prefix: :author
  delegate :author, to: :parent, prefix: :parent, allow_nil: true
  delegate :topic, :topic_id, :group, :group_id, :members, :guests, to: :parent

  define_counter_cache(:versions_count) { |comment| comment.versions.count }

  def title
    topic.topicable.title
  end

  def title_model
    topic.topicable
  end

  def author_id
    user_id
  end

  def real_participant
    author
  end

  def user
    super || AnonymousUser.new
  end

  def should_pin
    return false if body_format != "html"
    Nokogiri::HTML(self.body).css("h1,h2,h3").length > 0
  end

  def parent_event
    if parent.is_a? Stance
      Event.where(eventable_type: parent_type, eventable_id: parent_id).where('topic_id is not null').first
    else
      parent.created_event
    end
  end

  def created_event_kind
    :new_comment
  end

  def is_edited?
    edited_at.present?
  end

  private

  def has_body_or_attachment
    if !discarded_at && body_blank? && files.empty? && image_files.empty?
      errors.add(:body, I18n.t(:"activerecord.errors.messages.blank"))
    end
  end

  def body_blank?
    body.to_s.empty? || body.to_s == "<p></p>"
  end

  def parent_belongs_to_same_topic
    errors.add(:parent, "parent needs same topic") unless parent.topic == topic
  end
end
