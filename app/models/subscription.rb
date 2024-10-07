class Subscription < ApplicationRecord
  class MaxMembersExceeded < StandardError; end
  class NotActive < StandardError; end
  include SubscriptionConcern if Object.const_defined?('SubscriptionConcern')

  PAYMENT_METHODS = ["chargify", "manual", "barter", "paypal"]
  ACTIVE_STATES = %w[active on_hold pending]

  scope :dangling, -> { joins('LEFT JOIN groups ON subscriptions.id = groups.subscription_id').where('groups.id IS NULL') }
  scope :active, -> { where(state: ACTIVE_STATES).where("expires_at is null OR expires_at > ?", Time.current) }
  scope :expired, -> { where(state: ACTIVE_STATES).where("expires_at < ?", Time.current) }
  scope :canceled, -> { where(state: :canceled) }

  has_many :groups
  belongs_to :owner, class_name: 'User'

  attr_accessor :chargify_product_id

  has_paper_trail

  def self.for(group)
    parent = group.parent_or_self
    parent.subscription || begin
      parent.subscription = Subscription.new
      parent.save
      parent.subscription
    end
  end

  def can_invite()
    parent_group = parent_or_self
    subscription = Subscription.for(parent_group)
    subscription.max_members && parent_group.org_members_count >= subscription.max_members
  end

  def level
    SubscriptionService::PLANS[self.plan][:level]
  end

  def config
    SubscriptionService::PLANS[Subscription.last.plan.to_sym]
  end

  def is_active?
    ACTIVE_STATES.include?(state) && (self.expires_at.nil? || self.expires_at > Time.current)
  end

  def management_link
    (self.info || {})['chargify_management_link']
  end

  def self.ransackable_associations(auth_object = nil)
    ["groups", "owner", "versions"]
  end
  
  def self.ransackable_attributes(auth_object = nil)
    ["activated_at",
     "canceled_at",
     "chargify_subscription_id",
     "created_at",
     "expires_at",
     "id",
     "info",
     "max_members",
     "max_orgs",
     "max_threads",
     "members_count",
     "owner_id",
     "payment_method",
     "plan",
     "renewed_at",
     "renews_at",
     "state",
     "updated_at"]
  end
end
