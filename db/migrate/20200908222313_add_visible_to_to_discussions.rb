class AddVisibleToToDiscussions < ActiveRecord::Migration[5.2]
  def change
    add_column :discussions, :visible_to, :string, default: 'group'
    Discussion.where(private: false).update_all(visible_to: 'public')
    Discussion.joins(:group).where('groups.parent_members_can_see_discussions = TRUE').update_all(visible_to: 'parent_group')
  end
end
