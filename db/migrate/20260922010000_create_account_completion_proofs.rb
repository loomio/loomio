class CreateAccountCompletionProofs < ActiveRecord::Migration[8.1]
  def change
    create_table :account_completion_proofs do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.boolean :name_managed, null: false, default: false
      t.datetime :expires_at, null: false
      t.timestamps
    end
    add_index :account_completion_proofs, :expires_at
  end
end
