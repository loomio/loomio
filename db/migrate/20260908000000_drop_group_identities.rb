class DropGroupIdentities < ActiveRecord::Migration[8.1]
  def change
    drop_table :group_identities, id: :serial do |t|
      t.integer :group_id, null: false
      t.integer :identity_id, null: false
      t.jsonb :custom_fields, default: {}, null: false
      t.timestamps precision: nil, null: false
      t.index :group_id
      t.index :identity_id
    end
  end
end
