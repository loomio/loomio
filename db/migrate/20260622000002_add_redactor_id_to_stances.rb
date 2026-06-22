class AddRedactorIdToStances < ActiveRecord::Migration[8.0]
  def change
    add_column :stances, :redactor_id, :integer unless column_exists?(:stances, :redactor_id)
  end
end
