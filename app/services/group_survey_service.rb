class GroupSurveyService

  def self.create(survey:, actor:, group:)
    byebug
    actor.ability.authorize! :create, group

    # stance.assign_attributes(participant: actor)
    # return false unless stance.valid?
    #
    # stance.poll.stances.where(participant: actor).update_all(latest: false)
    # stance.save!
    # stance.participant.save!
    # EventBus.broadcast 'stance_create', stance, actor
    # Events::StanceCreated.publish! stance
  end

  # def self.update(stance:, actor:, params:)
  #   actor.ability.authorize! :update, stance
  #   HasRichText.assign_attributes_and_update_files(stance, params)
  #   return false unless stance.valid?
  #   stance.save!
  #
  #   EventBus.broadcast 'stance_update', stance, actor
  # end
end
