class Visitor < ActiveRecord::Base
  include NullUser

  has_many :stances, as: :participant
end
