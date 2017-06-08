class AddPollUnsubscriptions < ActiveRecord::Migration
  def change
    create_table :poll_unsubscriptions do |t|
      t.belongs_to :poll, null: false
      t.belongs_to :user, null: false
      t.timestamps
    end
    add_index :poll_unsubscriptions, [:poll_id, :user_id], unique: true
  end
end
