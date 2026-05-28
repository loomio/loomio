class DropDemos < ActiveRecord::Migration[8.0]
  def change
    drop_table :demos do |t|
      t.integer  :author_id, null: false
      t.integer  :group_id, null: false
      t.string   :name, null: false
      t.string   :description
      t.datetime :recorded_at, null: false
      t.timestamps
      t.integer  :priority, default: 0, null: false
      t.string   :demo_handle
    end
  end
end
