class AddNewValuesToRecordEdit < ActiveRecord::Migration
  def up
    add_column :record_edits, :new_values, :hstore
    add_index :record_edits, [:record_type, :record_id]
  end
end
