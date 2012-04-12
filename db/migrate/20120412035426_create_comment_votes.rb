class CreateCommentVotes < ActiveRecord::Migration
  def change
    create_table :comment_votes do |t|
      t.references :comment
      t.references :user
      t.boolean :value

      t.timestamps
    end
    add_index :comment_votes, :comment_id
    add_index :comment_votes, :user_id
  end
end
