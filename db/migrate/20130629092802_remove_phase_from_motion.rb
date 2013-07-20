class RemovePhaseFromMotion < ActiveRecord::Migration
  def up
    remove_column :motions, :phase
  end

  def down
    add_column :motions, :phase, :string, default: 'voting', null: :false
    Motion.where('closed_at IS NOT NULL').update_all(phase: 'closed')
  end
end
