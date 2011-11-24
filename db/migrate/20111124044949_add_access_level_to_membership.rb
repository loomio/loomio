class AddAccessLevelToMembership < ActiveRecord::Migration
  def change
    add_column :memberships, :access_level, :string
  end
end
