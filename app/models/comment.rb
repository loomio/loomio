class Comment < ApplicationRecord
  include CustomCounterCache::Model
  include Translatable
  include Reactable
  include HasMentions
  include HasDrafts
  include HasCreatedEvent
  include HasEvents
  include HasRichText

  has_paper_trail only: [:body, :body_format]

  is_translatable on: :body
  is_mentionable  on: :body
  is_rich_text    on: :body

  belongs_to :discussion
  has_one :group, through: :discussion
  belongs_to :user
  belongs_to :parent, class_name: 'Comment'

  alias_attribute :author, :user
  alias_attribute :author_id, :user_id
  alias_method :draft_parent, :discussion

  has_many :documents, as: :model, dependent: :destroy

  validates_presence_of :user
  validate :has_body_or_document
  validate :parent_comment_belongs_to_same_discussion
  validate :documents_owned_by_author

  default_scope { includes(:user).includes(:documents).includes(:discussion) }

  scope :in_organisation, ->(group) { joins(:discussion).where("discussions.group_id": group.id) }
  scope :chronologically, -> { order('created_at asc') }

  delegate :name, to: :user, prefix: :user
  delegate :name, to: :user, prefix: :author
  delegate :email, to: :user, prefix: :user
  delegate :author, to: :parent, prefix: :parent, allow_nil: true
  delegate :participants, to: :discussion, prefix: :discussion
  delegate :group_id, to: :discussion, allow_nil: true
  delegate :full_name, to: :group, prefix: :group
  delegate :title, to: :discussion, prefix: :discussion
  delegate :locale, to: :user
  delegate :mailer, to: :discussion
  delegate :id, to: :group, prefix: :group
  delegate :groups, to: :discussion
  delegate :guest_group, to: :discussion
  delegate :guest_group_id, to: :discussion
  delegate :members, to: :discussion

  define_counter_cache(:versions_count) { |comment| comment.versions.count }

  def self.always_versioned_fields
    [:body]
  end

  def should_pin
    return false if body_format != "html"
    Nokogiri::HTML(self.body).css("h1,h2,h3").length > 0
  end

  def parent_event
    if parent # parent comment
      parent.created_event # parent comment's 'new_comment' event
    else
      discussion.created_event
    end
  end

  def purge_drafts_asynchronously?
    false
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
    group.members_can_edit_comments? or is_most_recent?
  end

  def users_to_not_mention
    User.where(username: parent&.author&.username)
  end

  private

  def documents_owned_by_author
    return if documents.pluck(:author_id).select { |user_id| user_id != user.id }.empty?
    errors.add(:documents, "Attachments must be owned by author")
  end

  def parent_comment_belongs_to_same_discussion
    if self.parent.present?
      unless discussion_id == parent.discussion_id
        errors.add(:parent, "Needs to have same discussion id")
      end
    end
  end

  def has_body_or_document
    if body.blank? && documents.blank?
      errors.add(:body, "Comment cannot be empty")
    end
  end
end
