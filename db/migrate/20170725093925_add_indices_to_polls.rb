class AddIndicesToPolls < ActiveRecord::Migration
  def change
    add_index :outcomes, :poll_id
    add_index :poll_did_not_votes, :poll_id
    add_index :poll_did_not_votes, :user_id
    add_index :poll_options, :poll_id
    add_index :poll_unsubscriptions, :poll_id
    add_index :poll_unsubscriptions, :user_id
    add_index :poll_references, :poll_id
    add_index :attachments, [:attachable_id, :attachable_type]
    add_index :groups, :archived_at
    add_index :invitations, :cancelled_at
    add_index :invitations, :single_use
  end
end
