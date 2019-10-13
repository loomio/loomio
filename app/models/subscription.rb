class Subscription < ApplicationRecord
  PAYMENT_METHODS = ["chargify", "manual", "barter", "paypal"]

  has_many :groups
  belongs_to :owner, class_name: 'User'

  attr_accessor :chargify_product_id

  def self.for(group)
    parent = group.parent_or_self
    parent.subscription || begin
      parent.subscription = Subscription.new
      parent.save
      parent.subscription
    end
  end

  def is_active?
    ['active', 'trialing'].include? self.state
  end

  def calculate_members_count
    Group.where(subscription_id: self.id).map(&:org_members_count).sum
  end
end
