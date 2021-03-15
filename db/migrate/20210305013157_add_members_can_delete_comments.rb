class AddMembersCanDeleteComments < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :members_can_delete_comments, :boolean, default: true, null: false
  end
end
