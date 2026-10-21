# An address can remain blocked after an account changes its email or is erased.
# Keep only a digest here; delivery snapshots hold the erasable feedback details.
class EmailSuppression < ApplicationRecord
  REASONS = %w[permanent_bounce complaint legacy_bounce legacy_complaint].freeze
  belongs_to :notification_delivery_event, optional: true
  belongs_to :cleared_by, class_name: 'User', optional: true
  scope :active, -> { where(cleared_at: nil) }
  validates :email_sha256, :source_key, presence: true
  validates :reason, inclusion: { in: REASONS }
  validates :clear_method, inclusion: { in: %w[sign_in administrator] }, allow_nil: true

  def self.address_digest(email)
    Digest::SHA256.hexdigest(email.strip.downcase)
  end

  def self.for_address(email)
    email.present? ? where(email_sha256: address_digest(email)) : none
  end

end
