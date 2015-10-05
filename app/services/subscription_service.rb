class SubscriptionService

  def self.available?
    ENV['CHARGIFY_APP_NAME'].present? && ENV['CHARGIFY_API_KEY'].present?
  end

  def initialize(group, actor)
    raise 'Chargify ENV variables are not correctly set! Please set CHARGIFY_APP_NAME and CHARGIFY_API_KEY.' unless self.class.available?
    actor.ability.authorize! :choose_subscription_plan, group
    @subscription = group.subscription
  end

  def start_gift!
    @subscription.update trial_ended_at:           Time.zone.now,
                         kind:                     :gift,
                         activated_at:             Time.zone.now,
                         expires_at:               nil,
                         plan:                     nil,
                         chargify_subscription_id: nil
  end

  def start_subscription!(subscription_id)
    return true if @subscription.chargify_subscription_id == subscription_id
    raise 'unable to fetch subscription' unless    chargify_subscription = chargify_service(subscription_id).fetch!
    @subscription.update_column :trial_ended_at,   chargify_subscription['activated_at'] if @subscription.kind == 'trial'
    @subscription.update kind:                     :paid,
                         activated_at:             chargify_subscription['activated_at'],
                         expires_at:               chargify_subscription['expires_at'],
                         plan:                     chargify_subscription['product']['handle'],
                         chargify_subscription_id: chargify_subscription['id']
  end

  def change_plan!(product_handle)
    return true if @subscription.plan == product_handle
    raise 'unable to update subscription' unless   chargify_subscription = chargify_service.change_plan!(product_handle)
    @subscription.update activated_at:             chargify_subscription['activated_at'],
                         expires_at:               chargify_subscription['expires_at'],
                         plan:                     chargify_subscription['product']['handle']
  end

  def end_subscription!
    return true if @subscription.kind != 'paid'
    raise 'unable to cancel subscription' unless   chargify_subscription = chargify_service.cancel!
    @subscription.update kind:                     :gift,
                         activated_at:             chargify_subscription['canceled_at'],
                         expires_at:               nil,
                         plan:                     nil,
                         chargify_subscription_id: nil
  end

  private

  def chargify_service(subscription_id = nil)
    @chargify_service ||= ChargifyService.new(subscription_id || @subscription.chargify_subscription_id)
  end

end
