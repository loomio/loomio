class RemoveItemableVersionIdFromTopicItems < ActiveRecord::Migration[8.1]
  def change
    remove_column :topic_items, :itemable_version_id, :integer
  end
end
