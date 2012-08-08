class AddVoteToEvents < ActiveRecord::Migration
  def change
    add_column :events, :vote_id, :integer
    add_index :events, :vote_id
  end
end
