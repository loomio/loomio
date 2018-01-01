class AddGuestGroupToDiscussion < ActiveRecord::Migration
  def change
    add_column :discussions, :guest_group_id, :integer
  end
end
