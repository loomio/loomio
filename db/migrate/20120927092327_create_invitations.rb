class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string :recipient_email
      t.string :access_level
      t.integer :inviter_id
      t.integer :group_id

      t.timestamps
    end
  end
end
