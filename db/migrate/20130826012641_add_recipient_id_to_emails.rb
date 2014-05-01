class AddRecipientIdToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :recipient_id, :integer
    add_index :emails, :recipient_id
  end
end
