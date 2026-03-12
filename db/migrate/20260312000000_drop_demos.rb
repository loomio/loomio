class DropDemos < ActiveRecord::Migration[7.0]
  def up
    drop_table :demos, if_exists: true
  end

  def down
    create_table :demos do |t|
      t.integer :author_id, null: false
      t.integer :group_id, null: false
      t.string :name, null: false
      t.string :description
      t.datetime :recorded_at, null: false
      t.timestamps
      t.integer :priority, default: 0, null: false
      t.string :demo_handle
      t.index :author_id
    end
  end
end
