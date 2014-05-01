class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.integer :user_id
      t.string :filename
      t.string :location
      t.integer :comment_id

      t.timestamps
    end

    add_index :attachments, :comment_id
  end
end
