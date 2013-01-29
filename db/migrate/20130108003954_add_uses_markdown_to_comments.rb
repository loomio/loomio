class AddUsesMarkdownToComments < ActiveRecord::Migration
  def up
    add_column :comments, :uses_markdown, :boolean, default: true, null: false
    change_column :comments, :uses_markdown, :boolean, default: false, null: false
  end

  def down
    remove_column :comments, :uses_markdown
  end
end
