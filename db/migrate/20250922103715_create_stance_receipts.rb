class CreateStanceReceipts < ActiveRecord::Migration[7.2]
  def change
    create_table :stance_receipts do |t|
      t.bigint :poll_id
      t.bigint :voter_id
      t.bigint :inviter_id
      t.datetime :invited_at
      t.boolean :vote_cast
      t.timestamps
    end
  end
end
