class CreateInvitationsAgain < ActiveRecord::Migration
  def up
    create_table :invitations do |t|
      t.string :recipient_email, null: false
      t.integer :inviter_id, null: false
      t.integer :group_id, null: false
      t.boolean :to_be_admin, null: false, default: false
      t.string :token, null: false
    end

    add_index :invitations, :token
    add_index :invitations, :group_id
  end

  def down
    remove_index :invitations, :column => :group_id
    remove_index :invitations, :column => :token
    drop_table :invitations
  end
end
