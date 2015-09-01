class AddNewIndexesSept02 < ActiveRecord::Migration
  def change
    add_index :discussions, :last_activity_at
    add_index :discussions, :private
    add_index :motions, :closing_at
    add_index :motions, :closed_at
    add_index :memberships, :volume
    add_index :groups, :parent_members_can_see_discussions
  end
end
