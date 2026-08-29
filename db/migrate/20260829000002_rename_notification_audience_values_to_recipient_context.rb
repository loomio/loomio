class RenameNotificationAudienceValuesToRecipientContext < ActiveRecord::Migration[8.1]
  def change
    rename_column :notifications, :audience_values, :recipient_context
  end
end
