class Visitor < ActiveRecord::Base
  include NullUser
  include HasAvatar
  include UsesWithoutScope
  has_secure_token :participation_token

  before_create :set_avatar_initials

  belongs_to :community, class_name: "Communities::Base"
  has_many :poll_communities, through: :community
  has_many :polls, through: :poll_communities
  has_many :stances, as: :participant

  scope :can_receive_email, -> { where(revoked: false).where('email IS NOT NULL') }
  scope :undecided_for, ->(poll) {
    joins(:polls).joins(
      "LEFT OUTER JOIN stances
       ON  stances.participant_type = 'Visitor'
       AND stances.participant_id = visitors.id"
    ).where('stances.id': nil, 'polls.id': poll.id)
  }

end
