class OutcomeService
  def self.create(outcome:, actor:)
    actor.ability.authorize! :create, outcome

    return false unless outcome.valid?
    outcome.save!

    EventBus.broadcast 'outcome_create', outcome, actor
  end

  def self.update(outcome:, params:, actor:)
    actor.ability.authorize! :update, outcome

    outcome.assign_attributes(params)
    return false unless outcome.valid?
    outcome.save!

    EventBus.broadcast 'outcome_update', outcome, actor, params
  end
end
