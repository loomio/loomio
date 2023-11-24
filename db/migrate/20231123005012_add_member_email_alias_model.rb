class AddMemberEmailAliasModel < ActiveRecord::Migration[7.0]
  def change
    create_table :member_email_aliases do |t|
      t.citext :email, null: false
      t.boolean :require_dkim, null: false, default: true
      t.boolean :require_spf, null: false, default: true
      t.integer :user_id
      t.integer :group_id, null: false
      t.integer :author_id, null: false
      t.timestamps
    end
  end
end
