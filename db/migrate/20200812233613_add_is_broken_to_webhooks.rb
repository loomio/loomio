class AddIsBrokenToWebhooks < ActiveRecord::Migration[5.2]
  def change
    add_column :webhooks, :is_broken, :boolean, default: false, null: false
  end
end
