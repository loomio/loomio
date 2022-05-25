class AddWebhookKindToChatbots < ActiveRecord::Migration[6.1]
  def change
    add_column :chatbots, :webhook_kind, :string, default: nil
  end
end
