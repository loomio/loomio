class PasskeyCredential < ApplicationRecord
  belongs_to :user

  validates :external_id, presence: true, uniqueness: true
  validates :public_key, presence: true
  validates :user_handle, presence: true
  validates :sign_count, numericality: { greater_than_or_equal_to: 0 }
  validates :name, presence: true, length: { maximum: 100 }
end
