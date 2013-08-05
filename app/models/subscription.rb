class Subscription < ActiveRecord::Base
  attr_accessible :amount, :profile_id

  belongs_to :group

  validates_presence_of :amount, :group
end
