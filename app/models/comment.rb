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

  validate :parent_comment_belongs_to_same_topic
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

  before_validation :assign_parent_if_nil

  delegate :name, to: :user, prefix: :author
  delegate :author, to: :parent, prefix: :parent, allow_nil: true

  define_counter_cache(:versions_count) { |comment| comment.versions.count }

  def topic
    case parent
    when Comment then parent.topic
    when Discussion then parent.topic
    when Poll then parent.topic
    when Stance then parent.poll.topic
    else nil
    end
  end

  def discussion
    topic&.topicable if topic&.topicable_type == 'Discussion'
  end

  def discussion_id
    topic&.topicable_id if topic&.topicable_type == 'Discussion'
  end

  def discussion_id=(id)
    return if id.blank?
    self.parent ||= Discussion.find_by(id: id)
  end

  def group
    topic&.group
  end

  def group_id
    topic&.group_id
  end

  def title
    topic&.topicable&.title
  end

  def members
    topic&.members || User.none
  end

  def guests
    topic&.guests || User.none
  end

  def title_model
    topic&.topicable || self
  end

  def author_id
    user_id
  end

  def real_participant
    author
  end

  def assign_parent_if_nil
    self.parent = self.discussion if self.parent_id.nil? && self.parent_type.nil? && respond_to?(:discussion) && self.discussion.present?
  end

  def poll
    topic&.topicable if topic&.topicable_type == 'Poll'
  end

  def poll_id
    topic&.topicable_id if topic&.topicable_type == 'Poll'
  end

  def user
    super || AnonymousUser.new
  end

  def should_pin
    return false if body_format != "html"
    Nokogiri::HTML(self.body).css("h1,h2,h3").length > 0
  end

  def parent_event
    if parent.nil?
      topicable = topic&.topicable
      if topicable
        self.parent = topicable
        save!(validate: false)
      end
    end

    if parent.is_a? Stance
      Event.where(eventable_type: parent_type, eventable_id: parent_id).where('topic_id is not null').first
    else
      parent.created_event
    end
  end

  def created_event_kind
    :new_comment
  end

  def is_most_recent?
    discussion&.comments&.last == self
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

  def parent_comment_belongs_to_same_topic
    # if someone replies to a deleted comment (in practice, by email), reparent to the topicable
    if parent.nil?
      topicable = topic&.topicable
      self.parent = topicable if topicable
    end

    return if parent.nil? # standalone comment without topic context

    # Both comment and parent should resolve to the same topic
    parent_topic = case parent
                   when Comment then parent.topic
                   when Discussion then parent.topic
                   when Poll then parent.topic
                   when Stance then parent.poll.topic
                   else nil
                   end

    unless topic.nil? || parent_topic.nil? || topic == parent_topic
      errors.add(:parent, "Needs to have same topic")
    end
  end
end
