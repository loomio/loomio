class CreateEmailIntegrations < ActiveRecord::Migration
  def change
    create_table :email_integrations do |t|
      t.string  :user_id,               null: false
      t.string  :token,                 null: false
      t.integer :email_integrable_id,   null: false
      t.string  :email_integrable_type, null: false

      t.timestamps
    end

    add_index :email_integrations, :token
  end
end
