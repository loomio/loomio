class Session < ApplicationRecord
  belongs_to :user

  before_create { self.token = SecureRandom.urlsafe_base64(32) }
end
