class AddRevokedAtToStances < ActiveRecord::Migration[5.2]
  def change
    add_column :stances, :revoked_at, :datetime
  end
end
