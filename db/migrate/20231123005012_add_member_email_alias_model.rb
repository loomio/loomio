class AddMemberEmailAliasModel < ActiveRecord::Migration[7.0]
  def change
    create_table :member_email_aliases do |t|
      t.string :email
      t.boolean :must_validate, null: false, default: true
      t.integer :user_id, null: false
      t.integer :group_id, null: false
      t.integer :author_id, null: false
      t.timestamps
    end
  end
end
