class Subscription < ApplicationRecord
  class MaxMembersExceeded < StandardError; end
  class MaxThreadsExceeded < StandardError; end
  class NotActive < StandardError; end
  include SubscriptionConcern if Object.const_defined?('SubscriptionConcern')

  PAYMENT_METHODS = %w[barter none chargify loomio_subscriptions manual paypal].freeze
  # Billing services map their own states onto these when updates arrive.
  # Active and pending subscriptions keep their groups working until expires_at.
  # Past due, on hold and canceled subscriptions make their groups read-only.
  STATES = %w[active pending past_due on_hold canceled].freeze
  ACTIVE_STATES = %w[active pending].freeze

  validates :state, inclusion: { in: STATES }

  scope :active, -> { where(active_sql) }

  has_many :groups
  belongs_to :owner, class_name: 'User'

  attr_accessor :chargify_product_id

  has_paper_trail

  # The organisation's subscription, or the unsaved free tier when it has none.
  def self.for(group)
    group.parent_or_self.subscription || Subscription.new
  end

  # The organisation's subscription, created and linked when it has none.
  def self.for!(group)
    parent = group.parent_or_self
    parent.subscription || parent.create_subscription!.tap { parent.save! }
  end

  # The single definition of an active subscription, shared by is_active?,
  # Group.enabled and Group#subscription_active?.
  def self.active_sql(table = table_name)
    sanitize_sql_array([
      "#{table}.state IN (:states) AND (#{table}.expires_at IS NULL OR #{table}.expires_at > :now)",
      { states: ACTIVE_STATES, now: Time.current }
    ])
  end

  def is_active?
    ACTIVE_STATES.include?(state) && (expires_at.nil? || expires_at > Time.current)
  end

  def management_link
    (self.info || {})['chargify_management_link']
  end
end
