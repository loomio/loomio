class CreateStanceReceipts < ActiveRecord::Migration[7.2]
  def change
    create_table :stance_receipts do |t|
      t.references :poll, foreign_key: true
      t.references :voter, foreign_key: { to_table: :users }
      t.references :inviter, foreign_key: { to_table: :users }
      t.datetime :invited_at
      t.boolean :vote_cast
      t.timestamps
    end
  end
end
