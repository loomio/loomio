class Comment < ActiveRecord::Base
  include Twitter::Extractor
  include Translatable

  has_paper_trail

  belongs_to :discussion, counter_cache: true
  belongs_to :user

  has_many :comment_votes, :dependent => :destroy
  has_many :events, :as => :eventable, :dependent => :destroy
  has_many :attachments

  validates_presence_of :user
  validate :has_body_or_attachment
  validate :attachments_owned_by_author

  after_initialize :set_defaults
  default_scope include: [:user, :attachments, :discussion]

  delegate :name, :to => :user, :prefix => :user
  delegate :email, :to => :user, :prefix => :user
  delegate :participants, :to => :discussion, :prefix => :discussion
  delegate :group, :to => :discussion
  delegate :full_name, :to => :group, :prefix => :group
  delegate :title, :to => :discussion, :prefix => :discussion

  serialize :liker_ids_and_names, Hash

  alias_method :author, :user
  alias_method :author=, :user=

  # Helper class method that allows you to build a comment
  # by passing a discussion object, a user_id, and comment text
  def self.build_from(discussion, user, body, options = {})
    c = self.new
    c.discussion = discussion
    c.body = body
    c.user = user
    c.uses_markdown = options[:uses_markdown] || false
    if options[:attachments].present?
      c.attachment_ids = options[:attachments].map{|s| s.to_i}
      c.attachments_count = options[:attachments].count
    end
    c
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
