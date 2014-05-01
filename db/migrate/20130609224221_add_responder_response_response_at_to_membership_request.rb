class AddResponderResponseResponseAtToMembershipRequest < ActiveRecord::Migration
  def change
    remove_column :membership_requests, :user_id

    add_column :membership_requests, :requestor_id, :integer
    add_column :membership_requests, :responder_id, :integer
    add_column :membership_requests, :response, :string
    add_column :membership_requests, :responded_at, :datetime

    add_index :membership_requests, :requestor_id
    add_index :membership_requests, :responder_id
    add_index :membership_requests, :response
  end
end
