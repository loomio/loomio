class CreateMotionReadLogs < ActiveRecord::Migration
  def change
    create_table :motion_read_logs do |t|
      t.integer :vote_activity_when_last_read
      t.integer :discussion_activity_when_last_read
      t.integer :motion_id
      t.integer :user_id
      t.timestamps

      t.timestamps
    end
  end
end
