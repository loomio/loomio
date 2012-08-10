class CommentVote < ActiveRecord::Base
  belongs_to :comment
  belongs_to :user
  has_many :events, :as => :eventable, :dependent => :destroy

  validates_uniqueness_of :user_id, :scope => :comment_id
  delegate :name, :to => :user, :prefix => :user
  delegate :user, :to => :comment, :prefix => :comment
  delegate :group_full_name, :discussion, :to => :comment
  delegate :title, :to => :discussion, :prefix => :discussion
end
