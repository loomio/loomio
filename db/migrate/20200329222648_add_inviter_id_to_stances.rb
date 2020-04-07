class AddInviterIdToStances < ActiveRecord::Migration[5.2]
  def change
    add_column :stances, :inviter_id, :integer
  end
end
