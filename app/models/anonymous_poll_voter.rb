class AnonymousPollVoter < ApplicationRecord
  belongs_to :poll
  belongs_to :voter, class_name: "User"
  belongs_to :inviter, class_name: "User", optional: true

  validates :voter_id, uniqueness: { scope: :poll_id }
  validate :poll_uses_detached_anonymous_voting
  validate :identity_cannot_change, on: :update
  validate :ballot_submission_cannot_be_reversed, on: :update

  private

  def poll_uses_detached_anonymous_voting
    errors.add(:poll, :invalid) unless poll&.detached_anonymous?
  end

  def identity_cannot_change
    if will_save_change_to_poll_id? || will_save_change_to_voter_id? || will_save_change_to_inviter_id?
      errors.add(:base, :invalid)
    end
  end

  def ballot_submission_cannot_be_reversed
    if will_save_change_to_ballot_submitted? && ballot_submitted_in_database
      errors.add(:ballot_submitted, :invalid)
    end
  end
end
