class Comment < ActiveRecord::Base
  include Twitter::Extractor
  include Translatable

  has_paper_trail only: [:body]
  acts_as_tree
  is_translatable on: :body

  belongs_to :discussion
  belongs_to :user

  has_many :comment_votes, -> { joins('INNER JOIN users ON comment_votes.user_id = users.id AND users.deactivated_at IS NULL' )}, dependent: :destroy

  has_many :events, as: :eventable, dependent: :destroy
  has_many :attachments, dependent: :destroy
  has_many :likers, through: :comment_votes, source: :user

  validates_presence_of :user
  validate :has_body_or_attachment
  validate :attachments_owned_by_author
  validate :parent_comment_belongs_to_same_discussion

  after_initialize :set_defaults
  after_destroy :call_comment_destroyed

  default_scope { includes(:user).includes(:attachments).includes(:discussion) }

  #scope :published, -> { where(published: true) }
  scope :chronologically, -> { order('created_at asc') }

  delegate :name, to: :user, prefix: :user
  delegate :name, to: :user, prefix: :author
  delegate :email, to: :user, prefix: :user
  delegate :participants, to: :discussion, prefix: :discussion
  delegate :group, to: :discussion
  delegate :full_name, to: :group, prefix: :group
  delegate :title, to: :discussion, prefix: :discussion
  delegate :locale, to: :user
  delegate :id, to: :group, prefix: :group

  serialize :liker_ids_and_names, Hash

  define_counter_cache :versions_count do |comment|
    comment.versions.count
  end

  alias_method :author, :user
  alias_method :author=, :user=
  attr_accessor :new_attachment_ids

  def discussion_title
    discussion.title
  end

  def parent_author
    parent.author if is_reply?
  end

  def published_at
    created_at
  end

  def author_name
    author.try(:name)
  end

  def author_id
    user_id
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

  def is_reply?
    parent.present?
  end

  def liker_names(max: 3)
    comment_votes.last(max).map(&:user_name)
  end

  def refresh_liker_ids_and_names!
    update liker_ids_and_names: self.comment_votes.reduce({}) { |hash, vote| hash[vote.user_id] = vote.user.name; hash }
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

  def likes_count
    comment_votes_count
  end

  def likers_include?(user)
    if liker_ids_and_names.respond_to? :keys
      liker_ids_and_names.keys.include?(user.id)
    end
  end

  private
  def call_comment_destroyed
    discussion.comment_destroyed!(self)
  end

  def parent_comment_belongs_to_same_discussion
    if self.parent.present?
      unless discussion_id == parent.discussion_id
        errors.add(:parent, "Needs to have same discussion id")
      end
    end
  end

  def set_defaults
    self.liker_ids_and_names ||= {}
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
