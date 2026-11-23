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
  NON_PAID_PLANS = %w[trial demo].freeze

  validates :state, inclusion: { in: STATES }

  scope :active, -> { where(active_sql) }

  has_many :groups
  belongs_to :owner, class_name: 'User'

  attr_accessor :chargify_product_id

  has_paper_trail
  before_save :sync_allow_email_invitations_with_plan
  after_update_commit :enqueue_chargify_cancellation, if: :saved_change_to_state?

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

  # Hosted trials and demos default allow_email_invitations to false so they
  # invite people with a shareable group link unless explicitly permitted.
  def self.email_invitations_allowed?(model:, actor:)
    return true unless AppConfig.app_features[:subscriptions]

    group = model.is_a?(Group) ? model : (model.group if model.respond_to?(:group))
    group.present? ? Subscription.for(group).allow_email_invitations : actor.email_invitations_allowed?
  end

  def allow_email_invitations=(value)
    @allow_email_invitations_explicit = true
    super
  end

  def trial?
    plan == 'trial'
  end

  def email_invitations_allowed?
    !AppConfig.app_features[:subscriptions] || allow_email_invitations
  end

  def is_active?
    ACTIVE_STATES.include?(state) && (expires_at.nil? || expires_at > Time.current)
  end

  def management_link
    (self.info || {})['chargify_management_link']
  end

  private

  # Entering a trial or demo disables email invitations unless explicitly set;
  # leaving one re-enables them unless explicitly set. Admins can still toggle
  # allow_email_invitations directly on any subscription.
  def sync_allow_email_invitations_with_plan
    return if @allow_email_invitations_explicit
    return unless will_save_change_to_plan?

    if NON_PAID_PLANS.include?(plan)
      self.allow_email_invitations = false
    elsif NON_PAID_PLANS.include?(plan_was)
      self.allow_email_invitations = true
    end
  ensure
    @allow_email_invitations_explicit = false
  end

  def enqueue_chargify_cancellation
    return unless state == "canceled" && payment_method == "chargify" && chargify_subscription_id.present?

    root_ids = groups.parents_only.limit(2).pluck(:id)
    return unless root_ids.one?

    WarnAndDiscardCanceledGroupWorker.enqueue_for(root_ids.first, self, "chargify", chargify_subscription_id)
  end
end
