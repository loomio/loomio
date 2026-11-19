class CreateTrialInvitationRecipients < ActiveRecord::Migration[8.1]
  def change
    create_table :trial_invitation_recipients do |t|
      t.inet :ip_address, null: false
      t.integer :actor_id, null: false
      t.integer :recipient_id, null: false
      t.datetime :invited_at, null: false
    end
    add_index :trial_invitation_recipients, [ :ip_address, :actor_id, :recipient_id ],
      unique: true, name: 'index_trial_invitation_recipients_identity'
    add_index :trial_invitation_recipients, [ :ip_address, :invited_at ]
    add_index :trial_invitation_recipients, :invited_at
    add_foreign_key :trial_invitation_recipients, :users, column: :actor_id, on_delete: :cascade
    add_foreign_key :trial_invitation_recipients, :users, column: :recipient_id, on_delete: :cascade
  end
end
