class Subscription < ActiveRecord::Base

  belongs_to :group

  validates_presence_of :amount, :group
  scope :non_zero, -> { where('amount > 0') }
  scope :zero, -> { where('amount = 0') }
end
