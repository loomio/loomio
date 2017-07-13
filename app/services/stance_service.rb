class StanceService
  def self.create(stance:, actor:)
    actor.ability.authorize! :create, stance

    if invitation = stance.poll.invitations.useable.find_by(token: actor.token)
      actor = invitation.unverified_user_from_recipient!(name: actor.name, email: actor.email) unless actor.is_logged_in?
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
