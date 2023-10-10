class AddLastUsedAtToWebhooks < ActiveRecord::Migration[7.0]
  def change
    add_column :webhooks, :last_used_at, :datetime
  end
end
