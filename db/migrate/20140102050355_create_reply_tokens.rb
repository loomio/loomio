class CreateReplyTokens < ActiveRecord::Migration
  def change
    create_table :reply_tokens do |t|
      t.references :user,                         null: false
      t.references :replyable, polymorphic: true, null: false

      t.string :token,                            null: false

      t.timestamps
    end

    add_index :reply_tokens, :token
  end
end
