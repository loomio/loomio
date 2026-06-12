class CreateSessionsAndAddPasswordDigest < ActiveRecord::Migration[8.0]
  def up
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :ip_address
      t.string :user_agent
      t.timestamps
    end

    rename_column :users, :encrypted_password, :password_digest
    remove_column :users, :authentication_token
    remove_column :users, :remember_created_at
    remove_column :users, :remember_token
    remove_column :users, :reset_password_sent_at
    remove_column :users, :reset_password_token
    remove_column :users, :unlock_token
  end

  def down
    add_column :users, :unlock_token, :string
    add_column :users, :reset_password_token, :string, limit: 255
    add_column :users, :reset_password_sent_at, :datetime
    add_column :users, :remember_token, :string
    add_column :users, :remember_created_at, :datetime
    add_column :users, :authentication_token, :string, limit: 255
    add_index :users, :unlock_token, unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :remember_token, name: :users_remember_token_idx

    rename_column :users, :password_digest, :encrypted_password
    drop_table :sessions
  end
end
