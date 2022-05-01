class AddTemplateBoolToDiscussions < ActiveRecord::Migration[6.1]
  def change
    add_column :discussions, :template, :boolean, default: false, null: false
  end
end
