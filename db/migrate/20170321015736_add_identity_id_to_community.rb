class AddIdentityIdToCommunity < ActiveRecord::Migration
  def change
    add_column :communities, :identity_id, :integer, null: true
  end
end
