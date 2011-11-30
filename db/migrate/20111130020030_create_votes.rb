class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.references :motion
      t.references :user
      t.string :position

      t.timestamps
    end
    add_index :votes, :motion_id
    add_index :votes, :user_id
  end
end
