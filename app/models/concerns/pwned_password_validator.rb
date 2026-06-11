# Validates passwords against the haveibeenpwned.com API.
# Replaces the devise-pwned_password gem.
#
# Uses the pwned gem (https://github.com/philnash/pwned) which employs
# the k-anonymity model: only the first 5 characters of the SHA-1 hash
# are sent to the API, so the full password hash is never exposed.
module PwnedPasswordValidator
  extend ActiveSupport::Concern

  included do
    validate :password_not_pwned, if: :password_required?
  end

  private

  def password_not_pwned
    return unless password.present?
    return unless Rails.env.production?

    if Pwned.pwned?(password)
      errors.add(:password, I18n.t('auth_form.pwned_password'))
    end
  rescue Pwned::TimeoutError, Pwned::Error => e
    # API failure shouldn't block sign-up; log and allow
    Rails.logger.warn("PwnedPasswordValidator lookup failed: #{e.message}")
  end
end
