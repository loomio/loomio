class ContactMessage < ActiveRecord::Base

  DESTINATIONS = [
    'contact',
    'tech',
    'press',
    'services',
    'translations'
  ]

  belongs_to :user
  validates_presence_of :name, :message, :destination
  validates :email, presence: true, email: true
  validates_inclusion_of :destination, in: DESTINATIONS

end
