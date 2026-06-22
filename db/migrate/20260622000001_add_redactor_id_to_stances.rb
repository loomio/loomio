class AddRedactorIdToStances < ActiveRecord::Migration[8.0]
  def change
    add_column :stances, :redactor_id, :integer
  end
end
