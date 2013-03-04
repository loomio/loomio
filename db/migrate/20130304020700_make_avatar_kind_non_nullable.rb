class MakeAvatarKindNonNullable < ActiveRecord::Migration
  def up
    change_column_default(:users, :avatar_kind, default: 'initials', null: false)
  end

  def down
  end
end
