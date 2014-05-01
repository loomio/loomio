class CreatePersonas < ActiveRecord::Migration
  def change
    create_table :personas do |t|
      t.references :user
      t.string :email

      t.timestamps
    end
    add_index :personas, :user_id
    add_index :personas, :email
  end
end
