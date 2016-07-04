class AddLocationToUsersAndGroups < ActiveRecord::Migration
  def change
    add_column :users, :country, :string
    add_column :users, :region, :string
    add_column :users, :city, :string

    add_column :groups, :country, :string
    add_column :groups, :region, :string
    add_column :groups, :city, :string
  end
end
