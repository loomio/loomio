class DropDocumentsTable < ActiveRecord::Migration[8.0]
  def up
    drop_table :documents if table_exists?(:documents)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
