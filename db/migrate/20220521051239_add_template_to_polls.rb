class AddTemplateToPolls < ActiveRecord::Migration[6.1]
  def change
    add_column :polls, :template, :boolean, default: false, null: false
  end
end
