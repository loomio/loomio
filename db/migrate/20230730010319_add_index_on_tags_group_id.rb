class AddIndexOnTagsGroupId < ActiveRecord::Migration[7.0]
  def change
    add_index :tags, :group_id
  end
end
