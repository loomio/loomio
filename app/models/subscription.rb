class Subscription < ActiveRecord::Base
  has_one :group
  validates :kind, presence: true
  validates :group, presence: true
  validates_inclusion_of :kind, in: ['trial', 'gift', 'paid']

end
