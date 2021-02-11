class RenameDiscussionTagsToTaggings < ActiveRecord::Migration[5.2]
  def change
    rename_table :discussion_tags, :taggings
    rename_column :tags, :discussion_tags_count, :taggings_count

    add_column :taggings, :taggable_type, :string, null: false, default: 'Discussion'
    rename_column :taggings, :discussion_id, :taggable_id

    change_column :taggings, :tag_id, :integer, null: false
    change_column :taggings, :taggable_id, :integer, null: false
    change_column :taggings, :taggable_type, :string, null: false, default: nil
    change_column :tags, :name, :citext, null: false, default: nil

    add_index :taggings, [:taggable_type, :taggable_id]
    add_index :taggings, :tag_id
    add_index :tags, :group_id
    add_index :tags, :name

  end
end
