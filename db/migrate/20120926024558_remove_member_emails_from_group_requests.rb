class RemoveMemberEmailsFromGroupRequests < ActiveRecord::Migration
  def up
    remove_column :group_requests, :member_emails
  end

  def down
    add_column :group_requests, :member_emails, :text
  end
end
