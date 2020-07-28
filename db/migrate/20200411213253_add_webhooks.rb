class AddWebhooks < ActiveRecord::Migration[5.2]
  def change
    drop_table :webhooks if table_exists? :webhooks
    create_table :webhooks
    add_column :webhooks, :group_id, :integer, null: false
    add_column :webhooks, :name, :string, null: false
    add_column :webhooks, :url, :string, null: false
    add_column :webhooks, :event_kinds, :jsonb, default: [], null: false
    add_column :webhooks, :created_at, :datetime
    add_column :webhooks, :updated_at, :datetime
    add_index :webhooks, :group_id
  end
end
