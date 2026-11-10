class Session < ApplicationRecord
  belongs_to :user
  has_many :push_subscriptions, dependent: :destroy

  scope :active, -> { where(revoked_at: nil) }
  scope :revoked, -> { where.not(revoked_at: nil) }

  def active?
    revoked_at.nil?
  end

  # The row remains as history, but authentication only accepts active sessions.
  # Serialize revocation with push registration and remove push credentials in
  # the same transaction. Repeated revocation preserves the original timestamp.
  def revoke!
    with_lock do
      update!(revoked_at: Time.current) if active?
      push_subscriptions.destroy_all
    end
  end

  def self.retention_days
    days = Integer(ENV.fetch("LOOMIO_SESSION_RETENTION_DAYS", 60))
    raise ArgumentError, "LOOMIO_SESSION_RETENTION_DAYS must be nonnegative" if days.negative?

    days
  end

  def self.purge_revoked!
    revoked.where("revoked_at <= ?", retention_days.days.ago).in_batches(of: 1_000).delete_all
  end
end
