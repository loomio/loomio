class RenameMembershipsEmailDiscussionProp < ActiveRecord::Migration
  def change
    rename_column :memberships, :email_new_discussion_and_proposal_notifications, :email_new_discussions_and_proposals
  end
end
