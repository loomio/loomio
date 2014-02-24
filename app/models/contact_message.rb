class ContactMessage < ActiveRecord::Base

  DESTINATIONS = [
    ['General enquiries',                             'contact@loomio.org'],
    ['Tech support / bug reports / feature requests', 'tech@loomio.org'],
    ['Media enquiries',                               'press@loomio.org'],
    ['Sales and customer enquiries',                  'sales@loomio.org'],
    ['Translation enquiries',                         'translations@loomio.org']
  ]

  belongs_to :user
  validates_presence_of :name, :message, :destination
  validates :email, presence: true, email: true
end
