class AddSubLevelToMembership < ActiveRecord::Migration
  def change
  	 add_column :memberships, :sub_level, :integer, :default => 1, :null => false
  end
end
