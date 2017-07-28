class StanceService
  def self.create(stance:, actor:)
    actor.ability.authorize! :create, stance

    actor = actor.create_user if !actor.is_logged_in?

    if invitation = stance.poll.invitations.useable.find_by(token: actor.token)
      InvitationService.redeem(invitation, actor)
    end

    stance.assign_attributes(participant: actor)
    return false unless stance.valid?
    stance.poll.stances.where(participant: actor).update_all(latest: false)
    stance.save!
    stance.participant.save!
    EventBus.broadcast 'stance_create', stance, actor
    Events::StanceCreated.publish! stance
  end
end
