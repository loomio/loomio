class AddPendingEmailChangeToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :email_change_pending, :citext
    add_column :users, :email_change_requested_at, :datetime
  end
end
