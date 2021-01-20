class MakeWebhookUrlNullable < ActiveRecord::Migration[5.2]
  def up
    change_column :webhooks, :url, :string, null: true
  end

  def down
    change_column :webhooks, :url, :string, null: false
  end
end
