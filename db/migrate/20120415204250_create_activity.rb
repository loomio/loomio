class CreateActivity < ActiveRecord::Migration
  def change
    create_table :activity do |t|
      t.integer :activity_count
      t.integer :user_id
      t.integer :motion_id

      t.timestamps
    end
    add_index :activity, :user_id
    add_index :activity, :motion_id
  end
end
