class Discussion < ActiveRecord::Base
  acts_as_commentable

  belongs_to :group
  has_many :motions
end
