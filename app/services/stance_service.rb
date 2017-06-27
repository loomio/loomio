class StanceService
  def self.create(stance:, actor:)
    actor.community ||= stance.poll.community_of_type(:public) if actor.is_a?(Visitor)
    actor.ability.authorize! :create, stance

    stance.assign_attributes(participant: actor)
    return false unless stance.valid?
    stance.poll.stances.where(participant: actor).update_all(latest: false)
    stance.save!
    stance.participant.save!
    EventBus.broadcast 'stance_create', stance, actor
    Events::StanceCreated.publish! stance
  end
end
