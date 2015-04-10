class ChangeReferralToNotNull < ActiveRecord::Migration
  def up
    non_referral_group_ids = GroupRequest.pluck(:group_id).compact;
    Group.parents_only.where('groups.id NOT IN (?)', non_referral_group_ids).update_all(is_referral: true)
    Group.where(is_referral: nil).update_all(is_referral: false)
    change_column :groups, :is_referral, :boolean, null: false, default: false
  end

  def down
    change_column :groups, :is_referral, :boolean, null: false, default: false
  end
end
