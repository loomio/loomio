class Visitor < ActiveRecord::Base
  include NullUser
  include HasAvatar
  include UsesWithoutScope
  has_secure_token :participation_token

  before_create :set_avatar_initials

  belongs_to :community, class_name: "Communities::Base"
  has_many :stances, as: :participant
end
