class AddPriorityToTemplates < ActiveRecord::Migration[6.1]
  def change
    add_column :templates, :priority, :integer, default: 0, null: false
  end
end
