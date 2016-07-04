class AddSendCountToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :send_count, :integer, null: true, default: 0
  end
end
