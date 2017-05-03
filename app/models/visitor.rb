class Visitor < ActiveRecord::Base
  include NullUser
  include HasAvatar
  include UsesWithoutScope
  has_secure_token :participation_token

  before_create :set_avatar_initials

  belongs_to :community, class_name: "Communities::Base"
  has_many :stances, as: :participant

  scope :can_receive_email, -> { where(revoked: false).where('email IS NOT NULL') }
end
