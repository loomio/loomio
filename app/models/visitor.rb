class Visitor < ActiveRecord::Base
  include NullUser
  include HasGravatar

  validates :name, presence: true
  validates :email, presence: true
  has_many :stances, as: :participant
  before_create :set_avatar_initials
end
