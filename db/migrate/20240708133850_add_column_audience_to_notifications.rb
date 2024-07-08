class AddColumnAudienceToNotifications < ActiveRecord::Migration[7.0]
  def change
    add_column :notifications, :audience, :string
  end
end
