class Comment < ActiveRecord::Base
  include Twitter::Extractor
  include Translatable

  has_paper_trail
  is_translatable on: :body

  belongs_to :discussion, counter_cache: true
  belongs_to :user

  has_many :comment_votes, :dependent => :destroy
  has_many :events, :as => :eventable, :dependent => :destroy
  has_many :attachments

  validates_presence_of :user
  validate :has_body_or_attachment
  validate :attachments_owned_by_author

  after_initialize :set_defaults
  after_destroy :send_discussion_comment_deleted!

  default_scope { includes(:user).includes(:attachments).includes(:discussion) }

  delegate :name, :to => :user, :prefix => :user
  delegate :name, :to => :user, :prefix => :author
  delegate :email, :to => :user, :prefix => :user
  delegate :participants, :to => :discussion, :prefix => :discussion
  delegate :group, :to => :discussion
  delegate :full_name, :to => :group, :prefix => :group
  delegate :title, :to => :discussion, :prefix => :discussion
  delegate :locale, to: :user

  serialize :liker_ids_and_names, Hash

  alias_method :author, :user
  alias_method :author=, :user=

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

  def mentioned_group_members
    usernames = extract_mentioned_screen_names(self.body)
    group.users.where(username: usernames)
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

  private
    def send_discussion_comment_deleted!
      discussion.comment_deleted!
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
