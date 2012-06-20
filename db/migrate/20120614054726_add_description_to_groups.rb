class AddDescriptionToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :description, :string
  end
end
