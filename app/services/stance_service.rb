class StanceService
  def self.verify(stance:, actor:)
    actor.ability.authorize! :verify, stance
    stance.update(participant: actor)
    EventBus.broadcast 'stance_verify', stance, actor
  end

  def self.destroy(stance:, actor:)
    actor.ability.authorize! :destroy, stance
    stance.destroy
    EventBus.broadcast 'stance_destroy', stance, actor
  end

  def self.create(stance:, actor:)
    actor.ability.authorize! :create, stance

    actor = actor.create_user if !actor.is_logged_in?


    stance.assign_attributes(participant: actor)
    return false unless stance.valid?

    if invitation = stance.poll.invitations.useable.find_by(token: actor.token)
      InvitationService.redeem(invitation, actor)
    end

    stance.poll.stances.where(participant: actor).update_all(latest: false)
    stance.save!
    stance.participant.save!
    EventBus.broadcast 'stance_create', stance, actor
    Events::StanceCreated.publish! stance
  end
end
