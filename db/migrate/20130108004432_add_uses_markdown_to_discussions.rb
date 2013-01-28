class AddUsesMarkdownToDiscussions < ActiveRecord::Migration
  def change
    add_column :discussions, :uses_markdown, :boolean, default: true, null:false
    change_column :discussions, :uses_markdown, :boolean, default: false, null: false
  end
end
