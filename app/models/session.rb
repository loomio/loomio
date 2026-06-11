class Session < ApplicationRecord
  belongs_to :user

  before_create :set_token_and_expiry

  scope :active, -> { where('last_active_at > ?', 2.weeks.ago) }

  def record_activity!
    touch(:last_active_at)
  end

  def expired?
    last_active_at < 2.weeks.ago
  end

  def self.find_by_token(token)
    find_by(token: token)
  end

  private

  def set_token_and_expiry
    self.token = SecureRandom.urlsafe_base64(32)
    self.last_active_at ||= Time.current
  end
end
