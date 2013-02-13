class AddUsesMarkdownToMotions < ActiveRecord::Migration
  def up
    add_column :motions, :uses_markdown, :boolean, default: true, null: false
    change_column :motions, :uses_markdown, :boolean, default: false, null: false
  end

  def down
    remove_column :motions, :uses_markdown
  end
end
