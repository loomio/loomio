class UserDeactivationResponse < ApplicationRecord
  belongs_to :user
  validates_presence_of :user_id, :body
  validates :body, {length: {maximum: Rails.application.secrets.max_message_length}}
end
