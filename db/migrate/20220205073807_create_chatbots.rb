class CreateChatbots < ActiveRecord::Migration[6.1]
  def change
    create_table :chatbots do |t|
      t.string :kind
      t.string :channel_name
      t.integer :author_id
      t.integer :group_id
      t.jsonb :auth
      t.timestamps
    end
    add_index :chatbots, :group_id
  end
end
