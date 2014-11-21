class MarkdownByDefault < ActiveRecord::Migration
  def change
    change_column :discussions, :uses_markdown, :boolean, default: false, null: false
    change_column :comments,    :uses_markdown, :boolean, default: false, null: false
    change_column :users,       :uses_markdown, :boolean, default: false, null: false
  end
end
