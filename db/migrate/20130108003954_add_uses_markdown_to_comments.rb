class AddUsesMarkdownToComments < ActiveRecord::Migration
  def change
    add_column :comments, :uses_markdown, :boolean, default: true, null: false
    change_column :comments, :uses_markdown, :boolean, default: false, null: false
  end
end
