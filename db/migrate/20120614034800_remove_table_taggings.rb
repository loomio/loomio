class RemoveTableTaggings < ActiveRecord::Migration
  def up
    remove_index(:taggings, :name => "index_taggings_on_taggable_id_and_taggable_type_and_context")
    remove_index(:taggings, :name => "index_taggings_on_tag_id")
    drop_table :taggings
    drop_table :tags
  end
end
