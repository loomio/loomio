class OutcomeService
  def self.create(outcome:, actor:)
    actor.ability.authorize! :create, outcome

    outcome.assign_attributes(author: actor)
    return false unless outcome.valid?
    outcome.poll.outcomes.update_all(latest: false)
    outcome.save!

    EventBus.broadcast 'outcome_create', outcome, actor
    Events::OutcomeCreated.publish!(outcome)
  end
end
