class RenameMotionTypeToPhase < ActiveRecord::Migration
  def up
    rename_column :motions, :motion_type, :phase
  end

  def down
    rename_column :motions, :phase, :motion_type
    Motion.reset_column_information
    @motions = Motion.all
    @motions.each do |m|
      m.motion_type = 'proposal'
      m.save!
    end
  end
end
