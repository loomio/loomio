class SetOutcomeAuthorForMotionsMigration
  def self.now

  end
end


    # Motion.reset_column_information
    # Motion.find_each do |motion|
    #   puts motion.id if motion.id % 100 == 0

    #   outcome_event = motion.events.where(kind: 'motion_outcome_created').last
    #   motion.update_attribute(:outcome_author_id, outcome_event.user.id) unless outcome_event.blank?
    # end