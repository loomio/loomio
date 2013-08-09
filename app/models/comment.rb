class Comment < ActiveRecord::Base
  attr_accessible :body, :uses_markdown
  include Twitter::Extractor

  has_paper_trail

  belongs_to :discussion, counter_cache: true
  belongs_to :user

  has_many :comment_votes
  has_many :events, :as => :eventable, :dependent => :destroy

  validates_presence_of :body, :user

  after_create :update_discussion_last_comment_at
  after_create :fire_new_comment_event
  after_destroy :update_discussion_last_comment_at

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
  # example in readme
  def self.build_from(obj, user_id, body, uses_markdown)
    c = self.new
    c.discussion_id = obj.id
    c.body = body
    c.user_id = user_id
    c.uses_markdown = uses_markdown
    c
  end

  #helper method to check if a comment has children
  def has_children?
    self.children.size > 0
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
    def fire_new_comment_event
      Events::NewComment.publish!(self)
    end

    def update_discussion_last_comment_at
      return if discussion.nil?
      discussion.update_attribute(:last_comment_at, created_at)
    end
end
