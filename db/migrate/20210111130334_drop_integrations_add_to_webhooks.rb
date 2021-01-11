class DropIntegrationsAddToWebhooks < ActiveRecord::Migration[5.2]
  def change
    drop_table :integrations
    add_column :token, :string
    add_column :author_id, :integer
    add_column :actor_id, :integer
    add_column :permissions, :integer, array: true, default: [], null: false
  end
end
