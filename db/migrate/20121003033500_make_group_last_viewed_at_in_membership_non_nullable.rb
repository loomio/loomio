class MakeGroupLastViewedAtInMembershipNonNullable < ActiveRecord::Migration
  def up
    change_column :memberships, :group_last_viewed_at, :datetime, :default => default_date, :null => false
  end

  def down
  end
end