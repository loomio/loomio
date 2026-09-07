class Subscription < ApplicationRecord
  class MaxMembersExceeded < StandardError; end
  class MaxThreadsExceeded < StandardError; end
  class NotActive < StandardError; end
  include SubscriptionConcern if Object.const_defined?('SubscriptionConcern')

  PAYMENT_METHODS = %w[barter none chargify loomio_subscriptions manual paypal].freeze
  STATES = %w[active on_hold pending past_due canceled].freeze
  ACTIVE_STATES = %w[active on_hold pending].freeze

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

end
