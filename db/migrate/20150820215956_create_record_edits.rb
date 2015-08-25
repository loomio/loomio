class CreateRecordEdits < ActiveRecord::Migration
  def change
    create_table :record_edits do |t|
      t.hstore :previous_values
      t.string :record_type
      t.integer :record_id
      t.timestamps null: false
    end
  end
end
