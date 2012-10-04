class MakeGroupLastViewedAtInMembershipNonNullable < ActiveRecord::Migration
  def up
    Membership.where(:group_last_viewed_at => nil).update_all :group_last_viewed_at => Time.now
    change_column :memberships, :group_last_viewed_at, :datetime, :null => false
    change_column_default :memberships, :group_last_viewed_at, nil
  end

  def down
    change_column :memberships, :group_last_viewed_at, :datetime, :null => true
  end
end