class AddGuestGroupToDiscussion < ActiveRecord::Migration
  def change
    add_column :discussions, :guest_group_id, :integer, index: true
    add_index :discussions, :guest_group_id, unique: true
  end
end
