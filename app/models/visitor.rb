class Visitor < ActiveRecord::Base
  include NullUser

  validates :name, presence: true
  validates :email, presence: true
  has_many :stances, as: :participant
end
