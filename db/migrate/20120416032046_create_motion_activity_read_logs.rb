class CreateMotionActivityReadLogs < ActiveRecord::Migration
  def change
    create_table :motion_activity_read_logs do |t|
      t.integer :last_read_at
      t.integer :motion_id
      t.integer :user_id
      t.timestamps
    end
  end
end
