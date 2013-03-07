class SetManuallyApprovedGroupRequests < ActiveRecord::Migration
  def up
   GroupRequest.where(status: 'approved', group_id: nil).update_all(status: 'manually_approved')
  end

  def down
   GroupRequest.where(status: 'manually_approved').update_all(status: 'approved')
  end
end
