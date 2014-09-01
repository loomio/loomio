class ChangeCommentsFromPolymorphicToNormal < ActiveRecord::Migration
  def up
    remove_column :comments, :commentable_type
    rename_column :comments, :commentable_id, :discussion_id
    add_index :comments, :discussion_id unless index_exists? :comments, :discussion_id
    #Rake::Task['upgrade_tasks:update_comments_counts'].invoke
    #Rake::Task['upgrade_tasks:update_read_comments_counts'].invoke
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
