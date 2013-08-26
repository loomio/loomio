class Subscription < ActiveRecord::Base

  belongs_to :group

  validates_presence_of :amount, :group
end
