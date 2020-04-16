class AddFormatToWebhooks < ActiveRecord::Migration[5.2]
  def change
    add_column :webhooks, :format, :string, null: false, default: "markdown"
  end
end
