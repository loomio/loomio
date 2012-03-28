class AddViewableByToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :viewable_by, :string
  end
end
