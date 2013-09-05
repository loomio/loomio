class Comment < ActiveRecord::Base
  include Twitter::Extractor

  has_paper_trail

  belongs_to :discussion, counter_cache: true
  belongs_to :user

  has_many :comment_votes
  has_many :events, :as => :eventable, :dependent => :destroy
  has_many :attachments

  validates_presence_of :user
  validate :has_body_or_attachment
  validate :attachments_owned_by_author

  after_create :update_discussion_last_comment_at
  after_create :fire_new_comment_event

  default_scope include: [:user], order: "id DESC"

  delegate :name, :to => :user, :prefix => :user
  delegate :email, :to => :user, :prefix => :user
  delegate :participants, :to => :discussion, :prefix => :discussion
  delegate :group, :to => :discussion
  delegate :full_name, :to => :group, :prefix => :group
  delegate :title, :to => :discussion, :prefix => :discussion

  alias_method :author, :user

  # Helper class method that allows you to build a comment
  # by passing a discussion object, a user_id, and comment text
  def self.build_from(discussion, user, body, options = {})
    c = self.new
    c.discussion = discussion
    c.body = body
    c.user = user
    c.uses_markdown = options[:uses_markdown] || false
    c.attachment_ids = options[:attachments].present? ? options[:attachments].map{|s| s.to_i} : nil
    c
  end

  def like(user)
    vote = comment_votes.build
    vote.user = user
    vote.save if persisted?
    vote
  end

  def unlike(user)
    comment_votes.where(:user_id => user.id).each(&:destroy)
  end

  def mentioned_group_members
    usernames = extract_mentioned_screen_names(self.body)
    group.users.where(username: usernames)
  end

  def non_mentioned_discussion_participants
    (discussion.participants - mentioned_group_members) - [author]
  end

  private
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

    def fire_new_comment_event
      Events::NewComment.publish!(self)
    end

    def update_discussion_last_comment_at
      if discussion.present?
        discussion.update_attribute(:last_comment_at, created_at)
      end
    end
end
