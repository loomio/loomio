class AddIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.string :identity_type, null: false
      t.belongs_to :user, null: false, index: true
      t.string :access_token, null: false
      t.jsonb :custom_fields, default: {}, null: false
      t.timestamps
    end
  end
end
