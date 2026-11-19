class TrialInvitationRecipient < ApplicationRecord
  belongs_to :actor, class_name: 'User'
  belongs_to :recipient, class_name: 'User'

  def self.purge_expired!
    where(invited_at: ..24.hours.ago).in_batches(of: 1000).delete_all
  end
end
