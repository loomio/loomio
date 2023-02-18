class CreateReceivedEmails < ActiveRecord::Migration[6.1]
  def change
    create_table :received_emails do |t|
      t.integer :group_id
      t.hstore :headers, default: {}, null: false
      t.string :body_text
      t.string :body_html
      t.boolean :spf_valid, null: false, default: false
      t.boolean :dkim_valid, null: false, default: false
      t.boolean :released, null: false, default: false
      t.timestamps
    end
  end
end
