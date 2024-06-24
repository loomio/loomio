class SimplifySubscriptions < ActiveRecord::Migration[7.0]
  def change
    Subscription.where(state: :trialing).update_all(state: :active)
    Subscription.where(plan: %w[was-gift was-paid]).update_all(plan: :free)
    Subscription.where(plan: :free).update_all(payment_method: :none)
  end
end
