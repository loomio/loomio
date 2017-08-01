class AddIndexToPollsGuestGroupId < ActiveRecord::Migration
  def change
    add_index :polls, :guest_group_id, unique: true
  end
end
