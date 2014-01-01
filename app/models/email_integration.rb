class EmailIntegration < ActiveRecord::Base

  extend FriendlyId
  friendly_id :token

  belongs_to :user
  belongs_to :email_integrable, polymorphic: true

  validates_presence_of :user, :email_integrable
  validates :token, presence: true, uniqueness: true
end
