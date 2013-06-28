class ChangeCommentsFromPolymorphicToNormal < ActiveRecord::Migration
  def up
    remove_column :comments, :commentable_type
    rename_column :comments, :commentable_id, :discussion_id
    add_index :comments, :discussion_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
