class CreateDidNotVotes < ActiveRecord::Migration
  def change
    create_table :did_not_votes do |t|
      t.references :user
      t.references :motion

      t.timestamps
    end
    add_index :did_not_votes, :user_id
    add_index :did_not_votes, :motion_id
  end
end
