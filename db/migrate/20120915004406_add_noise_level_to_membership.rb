class AddNoiseLevelToMembership < ActiveRecord::Migration
  def up
  	unless column_exists? :memberships, :noise_level
  		add_column :memberships, :noise_level, :integer, :default => 1, :null => false
  	end
  end

  def down
  	unless !column_exists? :memberships, :noise_level
  		remove_column :memberships, :noise_level
  	end
  end
end
