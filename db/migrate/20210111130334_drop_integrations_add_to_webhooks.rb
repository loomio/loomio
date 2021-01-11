class DropIntegrationsAddToWebhooks < ActiveRecord::Migration[5.2]
  def change
    drop_table :integrations
    add_column :webhooks, :token, :string
    add_column :webhooks, :author_id, :integer
    add_column :webhooks, :actor_id, :integer
    add_column :webhook, :permissions, :integer, array: true, default: [], null: false
  end
end
