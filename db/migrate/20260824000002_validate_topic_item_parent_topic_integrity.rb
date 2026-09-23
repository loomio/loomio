class ValidateTopicItemParentTopicIntegrity < ActiveRecord::Migration[8.1]
  FOREIGN_KEY_NAME = "topic_items_parent_same_topic"

  def up
    validate_foreign_key :topic_items, :topic_items, name: FOREIGN_KEY_NAME
    remove_foreign_key :topic_items, column: :parent_id
  end

  def down
    add_foreign_key :topic_items,
                    :topic_items,
                    column: :parent_id,
                    on_delete: :cascade,
                    validate: false
    validate_foreign_key :topic_items, :topic_items, column: :parent_id
  end
end
