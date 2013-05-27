class AddAcceptedByAndAcceptedAtToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :accepted_by_id, :integer
    add_column :invitations, :accepted_at, :datetime
  end
end
