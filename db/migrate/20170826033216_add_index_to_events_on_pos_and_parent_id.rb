class AddIndexToEventsOnPosAndParentId < ActiveRecord::Migration[4.2]
  def change
    add_index :events, [:parent_id, :position], order: :position, where: "(parent_id IS NOT NULL)"
  end
end
