class AddColumnCannotContributeToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :cannont_contribute, :boolean, default: false
  end
end
