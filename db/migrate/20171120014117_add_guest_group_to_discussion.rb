class AddGuestGroupToDiscussion < ActiveRecord::Migration[4.2]
  def change
    add_column :discussions, :guest_group_id, :integer
  end
end
