class Comment < ApplicationRecord
  include Discard::Model
  include HasVersionsCount
  include Translatable
  include Reactable
  include Bookmarkable
  include HasMentions
  include HasTopicItems
  include HasNotifications
  include HasRichText
  include Searchable

  def self.pg_search_insert_statement(id: nil, author_id: nil, topic_id: nil, poll_id: nil)
    content_str = "regexp_replace(CONCAT_WS(' ', comments.body, users.name), E'<[^>]+>', '', 'gi')"
    <<~SQL.squish
      INSERT INTO pg_search_documents (
        searchable_type,
        searchable_id,
        poll_id,
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
      SELECT 'Comment' AS searchable_type,
        comments.id AS searchable_id,
        CASE WHEN topics.topicable_type = 'Poll' THEN topics.topicable_id ELSE NULL END AS poll_id,
        topics.group_id as group_id,
        CASE WHEN topics.topicable_type = 'Discussion' THEN topics.topicable_id ELSE NULL END AS discussion_id,
        topic_items.topic_id AS topic_id,
        #{TopicItem.tags_sql_for("Comment", "comments.id")} AS tags,
        comments.user_id AS author_id,
        comments.created_at AS authored_at,
        #{content_str} AS content,
        to_tsvector('simple',#{content_str}) as ts_content,
        now() AS created_at,
        now() AS updated_at
      FROM comments
        LEFT JOIN topic_items ON topic_items.itemable_type = 'Comment' AND topic_items.itemable_id = comments.id
        LEFT JOIN topics ON topics.id = topic_items.topic_id
        LEFT JOIN discussions ON discussions.id = topics.topicable_id AND topics.topicable_type = 'Discussion'
        LEFT JOIN polls ON polls.id = topics.topicable_id AND topics.topicable_type = 'Poll'
        LEFT JOIN users ON users.id = comments.user_id
      WHERE comments.discarded_at IS NULL
        AND comments.id NOT IN (#{under_polls(Poll.discarded).select(:id).to_sql})
        AND topics.discarded_at IS NULL
        AND (
          (topics.topicable_type = 'Discussion' AND discussions.discarded_at IS NULL) OR
          (topics.topicable_type = 'Poll' AND polls.discarded_at IS NULL)
        )
        #{id ? " AND comments.id = #{id.to_i} LIMIT 1" : ""}
        #{author_id ? " AND comments.user_id = #{author_id.to_i}" : ""}
        #{topic_id ? " AND topic_items.topic_id = #{topic_id.to_i}" : ""}
        #{poll_id ? " AND comments.id IN (#{under_polls(Poll.where(id: poll_id)).select(:id).to_sql})" : ""}
    SQL
  end

  has_paper_trail only: [:body, :body_format, :user_id, :discarded_at, :discarded_by, :attachments]

  is_translatable on: :body
  is_mentionable  on: :body
  is_rich_text    on: :body

  belongs_to :user
  belongs_to :parent, polymorphic: true

  validates_presence_of :user, unless: :discarded_at

  validate :parent_cannot_change, on: :update
  validate :parent_allows_replies, on: :create
  validate :has_body_or_attachment
  validate :body_within_topic_limit

  alias_method :author, :user
  alias_method :author=, :user=

  delegate :name, to: :user, prefix: :author
  delegate :author, to: :parent, prefix: :parent, allow_nil: true
  delegate :topic, :topic_id, :group, :group_id, :members, :guests, to: :parent


  def title
    topic.topicable.title
  end

  def title_model
    topic.topicable
  end

  def author_id
    user_id
  end

  def user
    super || AnonymousUser.new
  end

  def should_pin
    return false if body_format != "html"
    Nokogiri::HTML(self.body).css("h1,h2,h3").length > 0
  end

  def parent_topic_item
    if parent.is_a? Stance
      TopicItem.where(itemable_type: parent_type, itemable_id: parent_id).where('topic_id is not null').first
    else
      parent.created_topic_item
    end
  end

  def created_topic_item_kind
    :new_comment
  end

  def is_edited?
    edited_at.present?
  end

  def parent_allows_replies?
    parent_type != 'Stance' || parent.poll.results_available?
  end

  # Follow domain parents so conversations remain complete when the display
  # depth cap makes a reply a sibling of its actual parent or enclosing poll.
  def self.under_polls(polls)
    where("comments.id IN (#{<<~SQL.squish})")
      WITH RECURSIVE poll_comments AS (
        SELECT id FROM comments
        WHERE (parent_type = 'Poll' AND parent_id IN (#{polls.select(:id).to_sql}))
          OR (parent_type = 'Stance' AND parent_id IN (
            SELECT id FROM stances WHERE poll_id IN (#{polls.select(:id).to_sql})
          ))
          OR (parent_type = 'Outcome' AND parent_id IN (
            SELECT id FROM outcomes WHERE poll_id IN (#{polls.select(:id).to_sql})
          ))
        UNION
        SELECT comments.id FROM comments
        JOIN poll_comments ON comments.parent_type = 'Comment' AND comments.parent_id = poll_comments.id
      )
      SELECT id FROM poll_comments
    SQL
  end

  private

  def parent_allows_replies
    errors.add(:parent, :invalid) unless parent_allows_replies?
  end

  def has_body_or_attachment
    if !discarded_at && body_blank? && files.empty? && image_files.empty?
      errors.add(:body, I18n.t(:"activerecord.errors.messages.blank"))
    end
  end

  def body_within_topic_limit
    return if discarded_at
    return unless topic&.comment_length_max.present?
    return if body_visible_text_length <= topic.comment_length_max

    errors.add(:body, I18n.t(:"comment_form.messages.too_long", count: topic.comment_length_max))
  end

  def body_blank?
    body.to_s.empty? || body.to_s == "<p></p>"
  end

  def parent_cannot_change
    if will_save_change_to_parent_id? || will_save_change_to_parent_type?
      errors.add(:parent, "cannot be changed")
    end
  end
end
