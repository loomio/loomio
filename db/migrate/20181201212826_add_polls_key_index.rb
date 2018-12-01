class AddPollsKeyIndex < ActiveRecord::Migration[5.1]
  def change
    add_index :polls, :key, unique: true
  end
end
