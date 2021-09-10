class CreateDemos < ActiveRecord::Migration[6.1]
  def change
    create_table :demos do |t|
      t.integer :group_id, null: false
      t.string :name, null: false
      t.string :description
      t.datetime :recorded_at, null: false
      t.boolean :published, null: false
      t.timestamps
    end
  end
end
