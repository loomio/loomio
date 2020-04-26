class AddIncludeBodyToWebhooks < ActiveRecord::Migration[5.2]
  def change
    add_column :webhooks, :include_body, :boolean, default: false
  end
end
