class PushSubscription < ApplicationRecord
  ENDPOINT_HOSTS = %w[
    fcm.googleapis.com
    updates.push.services.mozilla.com
    web.push.apple.com
  ].freeze

  belongs_to :user

  before_validation :set_endpoint_digest

  validates :endpoint, :endpoint_digest, :p256dh_key, :auth_key, presence: true
  validates :endpoint, length: { maximum: 2048 }
  validates :p256dh_key, :auth_key, length: { maximum: 512 }
  validates :name, length: { maximum: 100 }, allow_nil: true
  validates :user_agent, length: { maximum: 500 }, allow_nil: true
  validates :endpoint_digest,
            uniqueness: { conditions: -> { where(revoked_at: nil) } },
            if: :active_endpoint?
  validates :failure_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :endpoint_is_trusted

  scope :active, -> { where(revoked_at: nil).where("expires_at IS NULL OR expires_at > ?", Time.current) }

  def active?
    revoked_at.nil? && (expires_at.nil? || expires_at.future?)
  end

  def revoke!
    update!(revoked_at: Time.current)
  end

  private

  def set_endpoint_digest
    self.endpoint_digest = Digest::SHA256.hexdigest(endpoint.to_s) if endpoint.present?
  end

  def active_endpoint?
    revoked_at.nil?
  end

  # Push endpoints are submitted by the browser but the API remains callable
  # by arbitrary clients. Restrict delivery to browser push providers so this
  # worker cannot be used to request internal or attacker-selected URLs.
  def endpoint_is_trusted
    uri = URI.parse(endpoint.to_s)
    trusted = uri.scheme == "https" && uri.port == 443 && uri.userinfo.nil? && ENDPOINT_HOSTS.include?(uri.host)
    errors.add(:endpoint, :invalid) unless trusted
  rescue URI::InvalidURIError
    errors.add(:endpoint, :invalid)
  end
end
