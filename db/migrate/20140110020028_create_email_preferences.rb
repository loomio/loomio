class CreateEmailPreferences < ActiveRecord::Migration
  def change
    create_table :email_preferences do |t|
      t.references :user
      t.boolean :subscribed_to_proposal_closure_notifications, default: true, null: false
      t.boolean :subscribed_to_mention_notifications, default: true, null: false
      t.text :days_to_send, default: "", null: false
      t.integer :hour_to_send, default: 22, null: false
      t.datetime :next_activity_summary_sent_at, null: true

      t.timestamps
    end
    add_index :email_preferences, :user_id
  end
end
