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

  def self.pg_search_insert_statement(id: nil, author_id: nil, discussion_id: nil)
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
        discussions.group_id as group_id,
        discussions.id AS discussion_id,
        comments.user_id AS author_id,
        comments.created_at AS authored_at,
        #{content_str} AS content,
        to_tsvector('simple',#{content_str}) as ts_content,
        now() AS created_at,
        now() AS updated_at
      FROM comments
        LEFT JOIN discussions ON discussions.id = comments.discussion_id
        LEFT JOIN users ON users.id = comments.user_id
        #{discussion_id ? "LEFT JOIN events ON events.eventable_type = 'Comment' AND events.eventable_id = comments.id" : ""}
      WHERE comments.discarded_at IS NULL 
        AND discussions.discarded_at IS NULL 
        #{id ? " AND comments.id = #{id.to_i} LIMIT 1" : ""}
        #{author_id ? " AND comments.user_id = #{author_id.to_i}" : ""}
        #{discussion_id ? " AND events.discussion_id = #{discussion_id.to_i}" : ""}
    SQL
  end

  has_paper_trail only: [:body, :body_format, :user_id, :discarded_at, :discarded_by]

  is_translatable on: :body
  is_mentionable  on: :body
  is_rich_text    on: :body

  belongs_to :discussion
  belongs_to :user
  belongs_to :parent, polymorphic: true

  has_many :documents, as: :model, dependent: :destroy

  validates_presence_of :user, unless: :discarded_at

  validate :parent_comment_belongs_to_same_discussion
  validate :has_body_or_attachment

  alias_attribute :author, :user
  alias_attribute :author_id, :user_id

  scope :dangling, -> { joins('left join discussions on discussion_id = discussions.id').where('discussion_id is not null and discussions.id is null') }
  scope :in_organisation, ->(group) { includes(:user, :discussion).joins(:discussion).where("discussions.group_id": group.id_and_subgroup_ids) }

  before_validation :assign_parent_if_nil

  delegate :name, to: :user, prefix: :user
  delegate :name, to: :user, prefix: :author
  delegate :email, to: :user, prefix: :user
  delegate :author, to: :parent, prefix: :parent, allow_nil: true
  delegate :group, to: :discussion
  delegate :group_id, to: :discussion, allow_nil: true
  delegate :full_name, to: :group, prefix: :group
  delegate :locale, to: :user
  delegate :mailer, to: :discussion
  delegate :guests, to: :discussion
  delegate :members, to: :discussion
  delegate :title, to: :discussion

  define_counter_cache(:versions_count) { |comment| comment.versions.count }

  def assign_parent_if_nil
    self.parent = self.discussion if self.parent_id.nil?
  end

  def poll
    nil
  end

  def poll_id
    nil
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
      # if stance, the could be updated event. sucks i know
      Event.where(eventable_type: parent_type, eventable_id: parent_id).where('discussion_id is not null').first
    else
      parent.created_event
    end
  end

  def created_event_kind
    :new_comment
  end

  def is_most_recent?
    discussion.comments.last == self
  end

  def is_edited?
    edited_at.present?
  end

  def can_be_edited?
    group.members_can_edit_comments or is_most_recent?
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

  def parent_comment_belongs_to_same_discussion
    # if someone replies to a deleted comment (in practice, by email), reparent to the discussion
    self.parent = self.discussion if parent.nil? && discussion.present?

    unless discussion_id == parent.discussion_id
      errors.add(:parent, "Needs to have same discussion id")
    end
  end
end
