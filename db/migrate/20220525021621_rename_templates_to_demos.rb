class RenameTemplatesToDemos < ActiveRecord::Migration[6.1]
  def change
    rename_table :templates, :demos
    remove_column :demos, :group_id
    remove_column :demos, :record_type
    rename_column :demos, :record_id, :group_id
  end
end
