class CreateForwardEmailRules < ActiveRecord::Migration[7.0]
  def change
    create_table :forward_email_rules do |t|
      t.citext :handle, null: false
      t.string :email
    end
  end
end
