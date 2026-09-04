class MobileDevice < ApplicationRecord
  belongs_to :user
  has_many :mobile_refresh_tokens, dependent: :destroy
  has_many :mobile_access_tokens, dependent: :destroy
  has_many :mobile_web_session_tickets, dependent: :destroy
  has_many :mobile_relay_authorizations, dependent: :destroy
  has_one :mobile_push_registration, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }
  validates :platform, inclusion: { in: %w[ios] }
  validates :protocol_version, numericality: { only_integer: true, greater_than: 0 }

  scope :active, -> { where(revoked_at: nil) }

  def active?
    revoked_at.nil? && user&.active_for_authentication?
  end

  def revoke!(at: Time.current)
    push_registration = nil
    transaction do
      lock!
      update!(revoked_at: at) unless revoked_at
      mobile_access_tokens.where(revoked_at: nil).update_all(revoked_at: at)
      mobile_refresh_tokens.where(revoked_at: nil).update_all(revoked_at: at)
      mobile_web_session_tickets.where(consumed_at: nil).update_all(consumed_at: at)
      mobile_relay_authorizations.where(consumed_at: nil).update_all(consumed_at: at)
      push_registration = mobile_push_registration
    end
    if push_registration
      registration_id = push_registration.registration_id
      delivery_key_ciphertext = push_registration.delivery_key_ciphertext
      ActiveRecord.after_all_transactions_commit do
        DeleteMobileRelayRegistrationWorker.perform_later(
          push_registration.id,
          registration_id,
          delivery_key_ciphertext
        )
      end
    end
  end
end
