class DropDemos < ActiveRecord::Migration[8.1]
  def change
    drop_table :demos do |t|
      t.integer :author_id, null: false
      t.string :demo_handle
      t.string :description
      t.integer :group_id, null: false
      t.string :name, null: false
      t.integer :priority, default: 0, null: false
      t.datetime :recorded_at, precision: nil, null: false
      t.timestamps precision: nil, null: false

      t.index :author_id
    end
  end
end
