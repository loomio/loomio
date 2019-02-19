class Subscription < ApplicationRecord
  PAYMENT_METHODS = ["chargify", "manual", "barter", "paypal"]

  has_many :groups
  belongs_to :owner, class_name: 'User'

  def self.for(group)
    group.subscription || begin
      group.subscription = Subscription.new
      group.save
      group.subscription
    end
  end

  def is_active?
    ['active', 'trialing'].include? self.state
  end
end
