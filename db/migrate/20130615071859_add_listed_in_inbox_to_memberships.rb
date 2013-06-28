class AddListedInInboxToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :inbox_position, :integer, default: 0, null: true
  end
end
