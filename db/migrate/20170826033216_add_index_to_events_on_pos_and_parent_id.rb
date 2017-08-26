class AddIndexToEventsOnPosAndParentId < ActiveRecord::Migration
  def change
    add_index :events, [:parent_id, :pos], order: :pos, where: "(pos IS NOT NULL)"
  end
end
