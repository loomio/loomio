class UpdateAvatarInitials < ActiveRecord::Migration
  class User < ActiveRecord::Base
  end

  def up
    User.where("avatar_kind = ''").update_all(:avatar_kind => 'initials')
  end

  def down
  end
end
