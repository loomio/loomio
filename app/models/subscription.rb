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
    if ['active-monthly', 'active-annual', 'active-community-annual'].include? self.plan
      calculate_active_members_last_30_days_count
    else
      Group.where(subscription_id: self.id).map(&:org_members_count).sum
    end
  end

  def calculate_active_members_last_30_days_count
    Group.where(subscription_id: self.id, parent_id: nil).map { |parent_group| calculate_active_members_last_30_days_count_for(parent_group) }.sum
  end

  def calculate_active_members_last_30_days_count_for(parent_group)
    member_ids = Membership.active.where(group_id: parent_group.id_and_subgroup_ids).pluck(:user_id).uniq.compact
    Event.where(user_id: member_ids).where('created_at > ?', 30.days.ago).count('distinct user_id')
  end

end
