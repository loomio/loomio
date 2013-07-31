class Subscription < ActiveRecord::Base
  belongs_to :group
  attr_accessible :amount

  validates_presence_of :amount, :group
end
