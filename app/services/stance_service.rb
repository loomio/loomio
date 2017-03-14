class StanceService
  def self.create(stance:, actor:)
    actor.community ||= stance.poll.communities.detect { |c| c.includes?(actor) } unless actor.is_logged_in?
    actor.ability.authorize! :create, stance

    stance.assign_attributes(participant: actor)
    return false unless stance.valid?
    actor.stances.where(poll: stance.poll).update_all(latest: false)
    stance.save!
    EventBus.broadcast 'stance_create', stance, actor
    Events::StanceCreated.publish! stance
  end
end
