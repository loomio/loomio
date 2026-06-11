class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.string :ip_address
      t.string :user_agent
      t.string :token, null: false
      t.datetime :last_active_at
      t.timestamps
    end

    add_index :sessions, :token, unique: true
  end
end
