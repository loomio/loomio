class ChangeMotionOutcomeToText < ActiveRecord::Migration
  def change
    change_column :motions, :outcome, :text
  end
end
