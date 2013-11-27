class AddOutcomeAuthorToMotions < ActiveRecord::Migration
  def up
    add_column :motions, :outcome_author_id, :integer

    Motion.reset_column_information
    Motion.find_each do |motion|
      puts motion.id if motion.id % 100 == 0

      outcome_event = motion.events.where(kind: 'motion_outcome_created').last
      motion.update_attribute(:outcome_author_id, outcome_event.user.id) unless outcome_event.blank?
    end
  end

  def down
    remove_column :motions, :outcome_author_id
  end
end
