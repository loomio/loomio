class Comment < ActiveRecord::Base
  attr_accessible :body

  acts_as_nested_set :scope => [:commentable_id, :commentable_type]

  validates_presence_of :body
  validates_presence_of :user

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  #acts_as_voteable

  belongs_to :commentable, :polymorphic => true
  belongs_to :user
  has_many :comment_votes

  after_save :update_activity

  delegate :name, :to => :user, :prefix => :user

  # Helper class method that allows you to build a comment
  # by passing a commentable object, a user_id, and comment text
  # example in readme
  def self.build_from(obj, user_id, comment)
    c = self.new
    c.commentable_id = obj.id
    c.commentable_type = obj.class.base_class.name
    c.body = comment
    c.user_id = user_id
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
    CommentVote.create(comment: self, user: user, value: true)
  end

  def unlike(user)
    like = likes.find_by_user_id(user.id)
    like.destroy if like
  end

  def likes
    return comment_votes.where("value = true")
  end

  def can_be_liked_by?(user)
    if user
      user.groups.include?(discussion.group)
    end
  end

  def discussion
    return commentable if commentable_type == "Discussion"
  end

  def default_motion
    discussion.default_motion
  end

  private
    def update_activity
      discussion.update_activity if discussion
    end
end
