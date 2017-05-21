class PolymorphNotificationActor < ActiveRecord::Migration
  def change
    add_column :notifications, :actor_type, :string, default: "User", null: false
  end
end
