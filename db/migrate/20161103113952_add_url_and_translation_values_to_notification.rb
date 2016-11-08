class AddUrlAndTranslationValuesToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :translation_values, :jsonb, null: false, default: {}
    add_column :notifications, :url, :string
    add_column :notifications, :actor_id, :integer
    add_index  :notifications, :actor_id
  end
end
