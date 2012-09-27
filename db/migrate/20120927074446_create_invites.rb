class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.string :token
      t.references :inviter, :polymorphic => true
      t.string :recipient_email

      t.timestamps
    end
    add_index :invites, [:inviter_id, :inviter_type]
  end
end
