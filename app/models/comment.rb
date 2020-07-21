class Comment < ApplicationRecord
  include Discard::Model
  include CustomCounterCache::Model
  include Translatable
  include Reactable
  include HasMentions
  include HasCreatedEvent
  include HasEvents
  include HasRichText

  has_paper_trail only: [:body, :body_format, :user_id, :discarded_at, :discarded_by]

  is_translatable on: :body
  is_mentionable  on: :body
  is_rich_text    on: :body

  belongs_to :discussion
  has_one :group, through: :discussion
  belongs_to :user
  belongs_to :parent, class_name: 'Comment'

  has_many :documents, as: :model, dependent: :destroy

  validates_presence_of :user, unless: :discarded_at

  validate :parent_comment_belongs_to_same_discussion
  validate :has_body_or_attachment

  alias_attribute :author, :user
  alias_attribute :author_id, :user_id

  default_scope { includes(:user).includes(:documents) }

  scope :in_organisation, ->(group) { joins(:discussion).where("discussions.group_id": group.id) }

  delegate :name, to: :user, prefix: :user
  delegate :name, to: :user, prefix: :author
  delegate :email, to: :user, prefix: :user
  delegate :author, to: :parent, prefix: :parent, allow_nil: true
  delegate :group_id, to: :discussion, allow_nil: true
  delegate :full_name, to: :group, prefix: :group
  delegate :locale, to: :user
  delegate :mailer, to: :discussion
  delegate :members, to: :discussion
  delegate :title, to: :discussion

  define_counter_cache(:versions_count) { |comment| comment.versions.count }

  def user
    super || AnonymousUser.new
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

  def has_body_or_attachment
    if !discarded_at && body_blank? && files.empty? && image_files.empty?
      errors.add(:body, I18n.t(:"activerecord.errors.messages.blank"))
    end
  end

  def body_blank?
    body.to_s.empty? || body.to_s == "<p></p>"
  end

  def parent_comment_belongs_to_same_discussion
    if parent.present?
      unless discussion_id == parent.discussion_id
        errors.add(:parent, "Needs to have same discussion id")
      end
    end
  end
end
