class MapUnknownSubscriptionStates < ActiveRecord::Migration[8.1]
  # Matches Subscription::STATES when this migration was written.
  STATES = %w[active pending past_due on_hold canceled].freeze

  # Chargify states were stored as they arrived. failed_to_create is a signup
  # that never completed; any other unknown state is treated the same way.
  def up
    execute <<~SQL.squish
      UPDATE subscriptions SET state = 'canceled', updated_at = now()
      WHERE state NOT IN (#{STATES.map { |state| connection.quote(state) }.join(', ')})
    SQL
  end

  def down; end
end
