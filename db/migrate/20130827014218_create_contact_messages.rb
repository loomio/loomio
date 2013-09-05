class CreateContactMessages < ActiveRecord::Migration
  def change
    create_table :contact_messages do |t|
      t.string :name
      t.integer :user_id
      t.string :email
      t.text :message

      t.timestamps
    end
  end
end
