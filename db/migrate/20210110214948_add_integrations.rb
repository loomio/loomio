class AddIntegrations < ActiveRecord::Migration[5.2]
  def change
    create_table :integrations do |t|
      t.string :name, null: false
      t.string :token, null: false
      t.integer :group_id, null: false
      t.integer :actor_id, null: false
      t.integer :author_id, null: false
      t.string :permissions, array: true
    end

    add_index :integrations, :token, unique: true
    add_index :integrations, :group_id
  end
end
