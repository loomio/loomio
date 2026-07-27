class LegacyAnonymousVoteReason < ApplicationRecord
  self.primary_key = :anonymous_ballot_id

  belongs_to :anonymous_ballot

  validates :body, presence: true
  validate :poll_is_migrated_legacy_anonymous

  before_update { throw(:abort) }
  before_destroy { throw(:abort) }

  private

  def poll_is_migrated_legacy_anonymous
    errors.add(:anonymous_ballot, :invalid) unless anonymous_ballot&.poll&.legacy_anonymous?
  end
end
