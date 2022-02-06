class CreateChatbots < ActiveRecord::Migration[6.1]
  def change
    create_table :chatbots do |t|
      t.string :service
      t.string :server
      t.string :channel
      t.string :username
      t.string :password
      t.integer :author_id
      t.integer :group_id
      t.timestamps
    end
    add_index :chatbots, :group_id
  end
end
