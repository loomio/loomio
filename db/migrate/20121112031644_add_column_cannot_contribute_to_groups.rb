class AddColumnCannotContributeToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :cannot_contribute, :boolean, default: false
  end
end
