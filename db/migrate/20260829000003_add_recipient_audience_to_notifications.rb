class AddRecipientAudienceToNotifications < ActiveRecord::Migration[8.1]
  def change
    add_column :notifications, :recipient_audience, :string
  end
end
