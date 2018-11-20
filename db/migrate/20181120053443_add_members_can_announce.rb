class AddMembersCanAnnounce < ActiveRecord::Migration[5.1]
  def change
    add_column :groups, :members_can_announce, :boolean, default: true, null: false
  end
end
