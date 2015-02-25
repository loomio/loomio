class Comment < ActiveRecord::Base
  include Twitter::Extractor
  include Translatable

  has_paper_trail
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

  serialize :liker_ids_and_names, Hash

  alias_method :author, :user
  alias_method :author=, :user=
  attr_accessor :new_attachment_ids

  def published_at
    created_at
  end

  def author_role
    #lookup role from membership of author to comment group
    ['Program Coordinator', 'Visitor', 'Cooperative Member', 'Hat Wearer', 'Dog burger', 'Zip', 'Banana Phone User'].sample
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

  def like(user)
    liker_ids_and_names[user.id] = user.name
    like = comment_votes.build
    like.comment = self
    like.user = user
    like.save
    save
    like
  end

  def unlike(user)
    liker_ids_and_names.delete(user.id)
    comment_votes.where(:user_id => user.id).each(&:destroy)
    save
  end

  def refresh_liker_ids_and_names
    hash = {}
    self.liker_ids_and_names = comment_votes.each do |cv|
      hash[cv.user_id] = cv.user.name
    end
    self.liker_ids_and_names = hash
  end

  def mentioned_group_members
    usernames = extract_mentioned_screen_names(self.body)
    group.users.where(username: usernames).where('users.id != ?', author.id)
  end

  def non_mentioned_discussion_participants
    (discussion.participants - mentioned_group_members) - [author]
  end

  def likes_count
    comment_votes_count
  end

  def likers_include?(user)
    if liker_ids_and_names.respond_to? :keys
      liker_ids_and_names.keys.include?(user.id)
    end
  end

  def followers_without_author
    discussion.followers.where('users.id != ?', author_id)
  end

  def non_mentioned_followers_without_author
    ignored_user_ids = [author.id, mentioned_group_members.pluck(:id)].flatten
    discussion.followers.where('users.id NOT IN (?)', ignored_user_ids)
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
