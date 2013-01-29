class AddUsesMarkdownToDiscussions < ActiveRecord::Migration
  def up
    add_column :discussions, :uses_markdown, :boolean, default: true, null:false
    change_column :discussions, :uses_markdown, :boolean, default: false, null: false
  end

  def down
    remove_column :discussions, :uses_markdown
  end
end
