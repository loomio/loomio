class ChangeWebhooksAllowNullUrl < ActiveRecord::Migration[5.2]
  def change
    change_column :webhooks, :url, :string
  end
end
