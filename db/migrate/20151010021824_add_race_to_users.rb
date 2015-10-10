class AddRaceToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :race, :string
  end
end
