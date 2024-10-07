class AddAllowGuestsToSubscriptions < ActiveRecord::Migration[7.0]
  def change
    add_column :subscriptions, :allow_guests, :boolean, default: true, null: false
  end
end
