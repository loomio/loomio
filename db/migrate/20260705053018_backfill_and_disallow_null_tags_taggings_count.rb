class BackfillAndDisallowNullTagsTaggingsCount < ActiveRecord::Migration[8.0]
  def up
    execute "UPDATE tags SET taggings_count = 0 WHERE taggings_count IS NULL"
    change_column_null :tags, :taggings_count, false
  end

  def down
    change_column_null :tags, :taggings_count, true
  end
end
