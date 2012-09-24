class AddNoiseLevelToMembership < ActiveRecord::Migration
  def change
  	 add_column :memberships, :noise_level, :integer, :default => 1, :null => false
  end
end
