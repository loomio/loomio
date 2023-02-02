class MakeCommentParentPolymorphic < ActiveRecord::Migration[6.1]
  def change
    add_column :comments, :parent_type, :string
    add_index :comments, [:parent_type, :parent_id]
    Comment.where("parent_id is not null").update_all(parent_type: 'Comment')
    Comment.where("parent_id is null").update_all(parent_type: 'Discussion')
    Comment.where(parent_type: 'Discussion').update_all("parent_id = discussion_id")
    change_column :comments, :parent_type, :string, null: false
  end
end
