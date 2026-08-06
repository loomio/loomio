class AddMessageIdToReceivedEmails < ActiveRecord::Migration[7.2]
  def change
    add_column :received_emails, :message_id, :string
    add_index :received_emails, :message_id, unique: true
  end
end
