class AddClosingAtToMotion < ActiveRecord::Migration
  class Motion < ActiveRecord::Base
  end

  def up
    add_column :motions, :closing_at, :datetime
    rename_column :motions, :close_at, :closed_at
    Motion.all. each do |motion|
      motion.closing_at = motion.closed_at
      motion.closed_at = nil if motion.phase == 'voting'
      motion.save!
    end
  end

  def down
    rename_column :motions, :closed_at, :close_at
    Motion.all.each do |motion|
      if motion.close_at.nil?
        motion.close_at = motion.closing_at
        motion.save!
      end
    end
    remove_column :motions, :closing_at
  end
end
