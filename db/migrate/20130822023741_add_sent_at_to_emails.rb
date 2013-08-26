class AddSentAtToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :sent_at, :datetime
  end
end
