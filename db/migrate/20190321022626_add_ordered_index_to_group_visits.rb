class AddOrderedIndexToGroupVisits < ActiveRecord::Migration[5.2]
  def change
    remove_index :group_visits, :created_at
    add_index :group_visits, [:created_at], order: {created_at: :desc}
  end
end
