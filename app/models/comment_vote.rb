class CommentVote < ActiveRecord::Base
  belongs_to :comment
  belongs_to :user
  has_many :events, :dependent => :destroy

  validates_uniqueness_of :user_id, scope: :comment_id
  delegate :name, to: :user, prefix: :user
end
