class ChangeChatbotIncludeBodyToNotificationOnly < ActiveRecord::Migration[6.1]
  def change
    remove_column :chatbots, :include_body
    add_column :chatbots, :notification_only, :boolean, default: false, null: false
  end
end
