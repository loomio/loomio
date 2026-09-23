class LegacyAnonymousVoteReason < ApplicationRecord
  self.primary_key = :anonymous_ballot_id

  belongs_to :anonymous_ballot

  validates :body, presence: true
  validate :poll_is_closed_detached_anonymous

  before_update { throw(:abort) }
  before_destroy { throw(:abort) }

  private

  def poll_is_closed_detached_anonymous
    poll = anonymous_ballot&.poll
    errors.add(:anonymous_ballot, :invalid) unless poll&.closed? && poll&.detached_anonymous?
  end
end
