module Lockable
  extend ActiveSupport::Concern

  included do
    # These columns already exist (from Devise migration)
    # failed_attempts  :integer, default: 0
    # unlock_token     :string
    # locked_at        :datetime
  end

  MAX_ATTEMPTS = ENV.fetch('MAX_LOGIN_ATTEMPTS', 10).to_i
  UNLOCK_IN = 6.hours

  def access_locked?
    locked_at.present? && locked_at > UNLOCK_IN.ago
  end

  def lock_access!
    return if access_locked?
    update_columns(
      locked_at: Time.current,
      unlock_token: self.class.generate_unique_secure_token
    )
  end

  def unlock_access!
    update_columns(
      locked_at: nil,
      unlock_token: nil,
      failed_attempts: 0
    )
  end

  def increment_failed_attempts
    increment!(:failed_attempts)
    lock_access! if failed_attempts >= MAX_ATTEMPTS
  end

  def reset_failed_attempts
    update_column(:failed_attempts, 0) if failed_attempts > 0
  end
end
