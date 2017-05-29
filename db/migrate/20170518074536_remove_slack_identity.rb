class RemoveSlackIdentity < ActiveRecord::Migration
  def change
    remove_column :groups, :slack_identity_id, :integer
  end
end
