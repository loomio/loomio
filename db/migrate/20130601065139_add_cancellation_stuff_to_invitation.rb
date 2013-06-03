class AddCancellationStuffToInvitation < ActiveRecord::Migration
  def change
    add_column :invitations, :canceller_id, :integer
    add_column :invitations, :cancelled_at, :datetime
  end
end
