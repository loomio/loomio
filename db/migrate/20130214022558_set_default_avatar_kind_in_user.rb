class SetDefaultAvatarKindInUser < ActiveRecord::Migration
  class User < ActiveRecord::Base
  end

  def up
    User.where(:avatar_kind => nil).
         update_all(:avatar_kind => 'initials')
    User.where(:avatar_kind => "\"\"").
         update_all(:avatar_kind => 'initials')
    change_column_default(:users, :avatar_kind, 'initials')
  end

  def down
    change_column_default(:users, :avatar_kind, nil)
  end
end
