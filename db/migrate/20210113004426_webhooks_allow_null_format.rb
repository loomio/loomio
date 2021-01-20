class WebhooksAllowNullFormat < ActiveRecord::Migration[5.2]
  def up
    change_column :webhooks, :format, :string, null: true
  end

  def down
    change_column :webhooks, :format, :string, null: false
  end
end
