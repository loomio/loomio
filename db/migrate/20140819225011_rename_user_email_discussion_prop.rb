class RenameUserEmailDiscussionProp < ActiveRecord::Migration
  def change
    rename_column :users, :new_discussion_and_proposal_notifications_enabled, :email_new_discussions_and_proposals
  end
end
