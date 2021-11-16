class CreateTemplates < ActiveRecord::Migration[6.1]
  def change
    create_table :templates do |t|
      t.integer :group_id
      t.integer :author_id, null: false
      t.integer :record_id, null: false
      t.string :record_type, null: false
      t.string :name, null: false
      t.string :description
      t.datetime :recorded_at, null: false
      t.timestamps
    end
    add_index(:templates, :group_id)
    add_index(:templates, :author_id)
    add_index(:templates, [:record_type, :record_id])
  end
end
