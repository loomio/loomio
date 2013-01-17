class AddUsesMarkdownToUsers < ActiveRecord::Migration
  def change
    add_column :users, :uses_markdown, :boolean, default: false
  end
end
