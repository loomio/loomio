class AddTrialExtendedAtToSubscriptions < ActiveRecord::Migration[8.1]
  def change
    add_column :subscriptions, :trial_extended_at, :datetime
  end
end
