class AddListedInExploreToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :listed_in_explore, :boolean, default: false, null: false
    Group.where(is_visible_to_public: true).update_all(listed_in_explore: true)
  end
end
