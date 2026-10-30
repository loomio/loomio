class AddEventPollsAndCalendarSubscriptions < ActiveRecord::Migration[8.1]
  # Nullable schedule columns need no backfill. Existing availability polls
  # retain their stored type and are normalized when read by the application.
  def change
    add_column :polls, :event_starts_at, :datetime
    add_column :polls, :event_ends_at, :datetime
    add_column :polls, :event_all_day, :boolean, default: false, null: false
    add_column :polls, :event_location, :text
    add_column :polls, :event_cancelled_at, :datetime
    add_column :polls, :calendar_uid, :string
    add_column :polls, :calendar_sequence, :integer, default: 0, null: false
    add_reference :polls, :source_outcome, index: false

    create_table :calendar_subscriptions do |t|
      t.references :membership, null: false, index: { unique: true }, foreign_key: { on_delete: :cascade }
      t.string :token, null: false, index: { unique: true }
      t.timestamps
    end

    create_table :calendar_invitations do |t|
      t.references :poll, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :email, null: false
      t.string :token, null: false, index: { unique: true }
      t.integer :delivered_sequence
      t.datetime :delivered_at
      t.integer :response_sequence
      t.datetime :response_dtstamp
      t.timestamps
      t.index [:poll_id, :user_id], unique: true
    end
  end
end
