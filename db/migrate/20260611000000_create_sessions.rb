class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    unless table_exists?(:sessions)
      create_table :sessions do |t|
        t.references :user, null: false, foreign_key: true
        t.string :token, null: false
        t.string :ip_address
        t.string :user_agent
        t.timestamps
      end
      add_index :sessions, :token, unique: true
    else
      add_column :sessions, :token, :string, null: false, default: '' unless column_exists?(:sessions, :token)
      add_index :sessions, :token, unique: true unless index_exists?(:sessions, :token)
    end
  end
end
