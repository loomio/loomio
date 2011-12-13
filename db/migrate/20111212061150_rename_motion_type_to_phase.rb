class RenameMotionTypeToPhase < ActiveRecord::Migration
  class Motion < ActiveRecord::Base
  end

  def up
    rename_column :motions, :motion_type, :phase
    Motion.reset_column_information
    @motions_unvoted = Motion.all.map{|m| m if m.votes.size == 0}
    @motions_voted = Motion.all.map{|m| m if m.votes.size > 0}
    @motions_unvoted.each do |m| 
      m.phase = 'discussion'
      m.save!
    end
    @motions_voted.each do |m| 
      m.phase = 'voting'
      m.save!
    end

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
