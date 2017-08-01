class CreateGroupIdentities < ActiveRecord::Migration
  def change
    create_table :group_identities do |t|
      t.integer :group_id, null: false
      t.integer :identity_id, null: false
    end

    add_index :group_identities, :group_id
    add_index :group_identities, :identity_id
  end
end
