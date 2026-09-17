class AddResponseCommentToMembershipRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :membership_requests, :response_comment, :text
  end
end
