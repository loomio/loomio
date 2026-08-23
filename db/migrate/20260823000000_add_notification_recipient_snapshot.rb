class AddNotificationRecipientSnapshot < ActiveRecord::Migration[7.2]
  def change
    # Columns are created with notification_occurrences so the preparation
    # release has the complete target row shape. Kept as an idempotent migration
    # because this version was assigned before the sequence was corrected.
    add_column :notification_occurrences, :recipient_user_ids, :integer, array: true, null: false, default: [], if_not_exists: true
    add_column :notification_occurrences, :recipient_chatbot_ids, :integer, array: true, null: false, default: [], if_not_exists: true
  end
end
