class CreateChatbots < ActiveRecord::Migration[6.1]
  def change
    create_table :chatbots do |t|
      t.string :kind
      t.string :server
      t.string :channel
      t.string :access_token
      t.integer :author_id
      t.integer :group_id
      t.jsonb "event_kinds", default: [], null: false
      t.boolean "include_body", default: false
      t.timestamps
    end
    add_index :chatbots, :group_id
  end
end
