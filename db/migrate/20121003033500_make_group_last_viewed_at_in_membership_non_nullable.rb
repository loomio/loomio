class MakeGroupLastViewedAtInMembershipNonNullable < ActiveRecord::Migration
  def up
  	default_date = Time.now()
    Membership.update_all ["group_last_viewed_at = ?", default_date], ["group_last_viewed_at is NULL"]

    change_column :memberships, :group_last_viewed_at, :datetime, :default => default_date, :null => false
  end

  def down
  end
end