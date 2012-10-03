class MakeGroupLastViewedAtInMembershipNonNullable < ActiveRecord::Migration
  def up
    change_column :memberships, :group_last_viewed_at, :datetime, :null => false
    change_column_default :memberships, :group_last_viewed_at, nil
  end

  def down
  end
end