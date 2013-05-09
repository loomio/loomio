class CommentVote < ActiveRecord::Base
  default_scope include: :user
  belongs_to :comment, counter_cache: true
  belongs_to :user
  has_many :events, :as => :eventable, :dependent => :destroy

  validates_uniqueness_of :user_id, :scope => :comment_id
  validates_presence_of :user, :comment
  delegate :name, :to => :user, :prefix => :user
  delegate :user, :to => :comment, :prefix => :comment
  delegate :group_full_name, :discussion, :to => :comment
  delegate :group, :to => :discussion
  delegate :title, :to => :discussion, :prefix => :discussion
end
