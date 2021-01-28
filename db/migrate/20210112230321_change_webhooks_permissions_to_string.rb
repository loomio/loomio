class ChangeWebhooksPermissionsToString < ActiveRecord::Migration[5.2]
  def change
    change_column :webhooks, :permissions, :string, array: true, default: []
  end
end
