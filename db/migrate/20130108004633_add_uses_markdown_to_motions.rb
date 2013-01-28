class AddUsesMarkdownToMotions < ActiveRecord::Migration
  def change
    add_column :motions, :uses_markdown, :boolean, default: true, null: false
    change_column :motions, :uses_markdown, :boolean, default: false, null: false
  end
end
