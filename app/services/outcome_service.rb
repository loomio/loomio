class OutcomeService
  def self.announce(outcome:, actor:, params:)
    actor.ability.authorize! :announce, outcome

    users = UserInviter.where_or_create!(inviter: actor, emails: params[:emails], user_ids: params[:user_ids])
    Events::OutcomeAnnounced.publish!(outcome, actor, users)
    users
  end

  def self.create(outcome:, actor:)
    actor.ability.authorize! :create, outcome

    outcome.assign_attributes(author: actor)
    return false unless outcome.valid?
    outcome.poll.outcomes.update_all(latest: false)
    outcome.store_calendar_invite if outcome.should_send_calendar_invite
    outcome.save!

    EventBus.broadcast 'outcome_create', outcome, actor
    Events::OutcomeCreated.publish!(outcome)
  end
end
