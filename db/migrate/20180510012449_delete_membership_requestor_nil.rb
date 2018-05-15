class DeleteMembershipRequestorNil < ActiveRecord::Migration[5.1]
  def change
    MembershipRequest.where(requestor_id: nil).delete_all
  end
end
