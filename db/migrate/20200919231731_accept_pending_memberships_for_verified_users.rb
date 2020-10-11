class AcceptPendingMembershipsForVerifiedUsers < ActiveRecord::Migration[5.2]
  def change
    Membership.joins(:user)
      .where('users.email_verified': true)
      .where('memberships.accepted_at': nil)
      .update_all('accepted_at = memberships.created_at') 
  end
end
