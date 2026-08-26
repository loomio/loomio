class ReplaceTopicItemCustomFieldsWithPinnedTitle < ActiveRecord::Migration[8.1]
  def up
    add_column :topic_items, :pinned_title, :text
    execute <<~SQL.squish
      UPDATE topic_items
      SET pinned_title = custom_fields ->> 'pinned_title'
      WHERE custom_fields ? 'pinned_title'
    SQL
    remove_column :topic_items, :custom_fields
  end

  def down
    add_column :topic_items, :custom_fields, :jsonb, null: false, default: {}
    execute <<~SQL.squish
      UPDATE topic_items
      SET custom_fields = jsonb_build_object('pinned_title', pinned_title)
      WHERE pinned_title IS NOT NULL
    SQL
    remove_column :topic_items, :pinned_title
  end
end
