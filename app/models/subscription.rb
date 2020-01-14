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
    # allow groups in dunning or on hold to continue using the app
    self.state == 'active' or self.state == 'past_due' or self.state == 'on_hold' or (self.state == 'trialing' && self.expires_at > Time.current)
  end

  def calculate_members_count
    Group.where(subscription_id: self.id).map(&:org_members_count).sum
  end
end
