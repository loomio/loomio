class CreateHeyaTables < ActiveRecord::Migration[7.0]
  def change
    create_table :heya_campaign_memberships do |t|
      t.references :user, null: false, polymorphic: true, index: false

      t.string :campaign_gid, null: false
      t.string :step_gid, null: false
      t.boolean :concurrent, null: false, default: false

      t.datetime :last_sent_at, null: false

      t.timestamps
    end

    add_index :heya_campaign_memberships, [:user_type, :user_id, :campaign_gid], unique: true, name: :user_campaign_idx

    create_table :heya_campaign_receipts do |t|
      t.references :user, null: false, polymorphic: true, index: false

      t.string :step_gid, null: false

      t.datetime :sent_at

      t.timestamps
    end

    add_index :heya_campaign_receipts, [:user_type, :user_id, :step_gid], unique: true, name: :user_step_idx
  end
end
