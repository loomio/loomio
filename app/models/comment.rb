class Comment < ActiveRecord::Base
  include Twitter::Extractor
  acts_as_nested_set :scope => [:commentable_id, :commentable_type]
  has_paper_trail

  validates_presence_of :body
  validates_presence_of :user
  validates_inclusion_of :uses_markdown, :in => [true,false]

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  #acts_as_voteable

  belongs_to :commentable, :polymorphic => true
  belongs_to :user
  has_many :comment_votes
  has_many :events, :as => :eventable, :dependent => :destroy

  after_create :update_discussion_last_comment_at
  after_create :fire_new_comment_event
  after_destroy :update_discussion_last_comment_at

  attr_accessible :body, :uses_markdown

  default_scope order("id DESC")

  delegate :name, :to => :user, :prefix => :user
  delegate :email, :to => :user, :prefix => :user
  delegate :participants, :to => :discussion, :prefix => :discussion
  delegate :group, :to => :discussion
  delegate :full_name, :to => :group, :prefix => :group
  delegate :title, :to => :discussion, :prefix => :discussion

  alias_method :author, :user

  # Helper class method that allows you to build a comment
  # by passing a commentable object, a user_id, and comment text
  # example in readme
  def self.build_from(obj, user_id, comment)
    c = self.new
    c.commentable_id = obj.id
    c.commentable_type = obj.class.base_class.name
    c.body = comment
    c.user_id = user_id
    c.uses_markdown = User.find_by_id(user_id).uses_markdown?
    c
  end

  #helper method to check if a comment has children
  def has_children?
    self.children.size > 0
  end

  # Helper class method to lookup all comments assigned
  # to all commentable types for a given user.
  scope :find_comments_by_user, lambda { |user|
    where(:user_id => user.id).order('created_at DESC')
  }

  # Helper class method to look up all comments for
  # commentable class name and commentable id.
  scope :find_comments_for_commentable, lambda { |commentable_str, commentable_id|
    where(:commentable_type => commentable_str.to_s, :commentable_id => commentable_id).order('created_at DESC')
  }

  # Helper class method to look up a commentable object
  # given the commentable class name and id
  def self.find_commentable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id)
  end

  def can_be_deleted_by?(user)
    self.user == user
  end

  #
  # CUSTOM METHODS (not part of acts_as_commentable)
  #

  def like(user)
    comment_vote = CommentVote.new
    comment_vote.comment = self

    comment_vote.user = user
    comment_vote.value = true
    comment_vote.save
    comment_vote
  end

  def unlike(user)
    like = likes.find_by_user_id(user.id)
    like.destroy if like
  end

  def likes
    return comment_votes.where("value = true")
  end

  def discussion
    return commentable if commentable_type == "Discussion"
  end

  def current_motion
    discussion.current_motion
  end

  def mentioned_group_members
    users = []
    usernames = extract_mentioned_screen_names(self.body)
    usernames.uniq.each do |name|
      user = User.find_by_username(name)
      if user && user.group_ids.include?(discussion.group_id)
        users << user
      end
    end
    users
  end

  def other_discussion_participants
    discussion.participants - [author]
  end

  private
    def fire_new_comment_event
      Events::NewComment.publish!(self)
    end

    def update_discussion_last_comment_at
      discussion.last_comment_at = discussion.latest_comment_time
      discussion.save
    end

end
