class AddSigninToken < ActiveRecord::Migration
  def change
    create_table :login_tokens do |t|
      t.references :user
      t.string :token
      t.boolean :used, default: false, null: false
      t.timestamps
    end
  end
end
