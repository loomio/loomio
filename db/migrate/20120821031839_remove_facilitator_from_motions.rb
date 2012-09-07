class RemoveFacilitatorFromMotions < ActiveRecord::Migration
  def up
    remove_column :motions, :facilitator_id
  end

  def down
    add_column :motions, :facilitator_id
  end
end
