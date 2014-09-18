class ContactMessage < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :name, :message
  validates :email, presence: true, email: true
end
