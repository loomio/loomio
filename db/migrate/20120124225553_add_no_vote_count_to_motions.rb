class AddNoVoteCountToMotions < ActiveRecord::Migration
  def up
    add_column :motions, :no_vote_count, :integer
    Motion.reset_column_information
    change_column :motions, :phase, :string, default: 'voting'
    Motion.reset_column_information
    Motion.all.each do |m|
      m.phase = 'voting'
      m.save!
    end
  end
  def down
    remove_column :motions, :no_vote_count
  end
end
