class IndexEventsUserId < ActiveRecord::Migration[5.2]
  def change

    add_index :events, :user_id
  end
end
