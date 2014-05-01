class AddGroupPrivacyDefault < ActiveRecord::Migration
  def up
    change_column_default(:groups, :privacy, 'private')
  end

  def down
    change_column_default(:groups, :privacy, nil)
  end
end
