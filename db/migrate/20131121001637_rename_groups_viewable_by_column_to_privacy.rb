class RenameGroupsViewableByColumnToPrivacy < ActiveRecord::Migration
  def up
    rename_column :groups, :viewable_by, :privacy
    Group.reset_column_information
    Group.where(privacy: 'everyone').update_all(privacy: 'public')
    Group.where(privacy: 'members').update_all(privacy: 'secret')
  end

  def down
    rename_column :groups, :privacy, :viewable_by
    Group.reset_column_information
    Group.where(viewable_by: 'public').update_all(viewable_by: 'everyone')
    Group.where(viewable_by: 'secret').update_all(viewable_by: 'members')
  end
end
