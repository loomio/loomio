class Comment < ActiveRecord::Base
  include Twitter::Extractor
  include Translatable

  has_paper_trail only: [:body]
  is_translatable on: :body

  belongs_to :discussion
  belongs_to :user
  belongs_to :parent, class_name: 'Comment'

  alias_attribute :author, :user
  alias_attribute :author_id, :user_id

  has_many :comment_votes, -> { joins('INNER JOIN users ON comment_votes.user_id = users.id AND users.deactivated_at IS NULL' )}, dependent: :destroy

  has_many :events, as: :eventable, dependent: :destroy
  has_many :attachments, dependent: :destroy
  has_many :likers, through: :comment_votes, source: :user

  validates_presence_of :user
  validate :has_body_or_attachment
  validate :attachments_owned_by_author
  validate :parent_comment_belongs_to_same_discussion

  default_scope { includes(:user).includes(:attachments).includes(:discussion) }

  scope :chronologically, -> { order('created_at asc') }

  delegate :name, to: :user, prefix: :user
  delegate :name, to: :user, prefix: :author
  delegate :email, to: :user, prefix: :user
  delegate :author, to: :parent, prefix: :parent, allow_nil: true
  delegate :participants, to: :discussion, prefix: :discussion
  delegate :group, to: :discussion
  delegate :full_name, to: :group, prefix: :group
  delegate :title, to: :discussion, prefix: :discussion
  delegate :locale, to: :user
  delegate :id, to: :group, prefix: :group

  define_counter_cache(:versions_count) { |comment| comment.versions.count }
  attr_accessor :new_attachment_ids

  def is_most_recent?
    discussion.comments.last == self
  end

  def is_edited?
    edited_at.present?
  end

  def can_be_edited?
    group.members_can_edit_comments? or is_most_recent?
  end

  def mentioned_usernames
    extract_mentioned_screen_names(self.body).uniq
  end

  def mentioned_group_members
    group.users.where(username: mentioned_usernames).where('users.id != ?', author.id)
  end

  def new_mentions_in(body)
    self.class.new(body: body).mentioned_usernames - mentioned_usernames
  end

  def notified_group_members
    mentioned_group_members.without(author).without(parent.try(:author))
  end

  private
  def parent_comment_belongs_to_same_discussion
    if self.parent.present?
      unless discussion_id == parent.discussion_id
        errors.add(:parent, "Needs to have same discussion id")
      end
    end
  end

  def attachments_owned_by_author
    if attachments.present?
      if attachments.map(&:user_id).uniq != [user.id]
        errors.add(:attachments, "Attachments must be owned by author")
      end
    end
  end

  def has_body_or_attachment
    if body.blank? && attachments.blank?
      errors.add(:body, "Comment cannot be empty")
    end
  end
end
