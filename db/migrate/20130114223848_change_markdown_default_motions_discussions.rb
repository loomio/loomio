class ChangeMarkdownDefaultMotionsDiscussions < ActiveRecord::Migration
  def up
    change_column :discussions, :uses_markdown, :boolean, default: true, null: false
    change_column :motions, :uses_markdown, :boolean, default: true, null: false
  end

  def down
    change_column :discussions, :uses_markdown, :boolean, default: false, null: false
    change_column :motions, :uses_markdown, :boolean, default: false, null: false
  end
end
