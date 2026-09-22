class PasskeyChallenge < ApplicationRecord
  belongs_to :user, optional: true

  validates :challenge_digest, presence: true, uniqueness: true
  validates :ceremony, presence: true
  validates :expires_at, presence: true
end
