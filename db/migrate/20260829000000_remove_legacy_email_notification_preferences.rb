class RemoveLegacyEmailNotificationPreferences < ActiveRecord::Migration[8.1]
  def up
    remove_column :users, :email_when_mentioned
    remove_column :users, :email_when_proposal_closing_soon
  end

  def down
    add_column :users, :email_when_mentioned, :boolean, default: true, null: false
    add_column :users, :email_when_proposal_closing_soon, :boolean, default: false, null: false
  end
end
