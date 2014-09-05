class AddCommentsAreEditableToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :members_can_edit_comments, :boolean, default: true
  end
end
