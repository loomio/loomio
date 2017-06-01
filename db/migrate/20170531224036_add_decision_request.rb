class AddDecisionRequest < ActiveRecord::Migration
  def change
    create_table :received_emails do |t|
      t.string :token
      t.text :headers
      t.text :body
      t.string :sender_email, null: false
      t.timestamps
    end
  end
end
