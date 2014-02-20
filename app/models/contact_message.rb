class ContactMessage < ActiveRecord::Base
  
  DESTINATIONS = [
    ['General Inquiries',                             'contact@loomio.org'],
    ['Tech support / Bug reports / Feature requests', 'tech@loomio.org'],
    ['Media inquiries and leads',                     'press@loomio.org'],
    ['High touch and Loomio Plus sales leads',        'sales@loomio.org'],
    ['Translation inquiries',                         'translations@loomio.org']
  ]
  
  belongs_to :user
  validates_presence_of :name, :message, :destination
  validates :email, presence: true, email: true
end
