class StanceService
  def self.create(stance:, actor:)
    actor.ability.authorize!(:vote_in, stance.poll)

    stance.participant = actor
    stance.cast_at ||= Time.zone.now
    stance.save!
    stance.poll.update_counts!

    event = Events::StanceCreated.publish!(stance)
    MessageChannelService.publish_models([event], scope: {current_user_id: actor.id}, user_id: actor.id)
    event
  end

  def self.update(stance:, actor:, params: )
    actor.ability.authorize!(:update, stance)
    stance.stance_choices = []
    stance.assign_attributes_and_files(params)
    stance.cast_at ||= Time.zone.now
    stance.save!
    stance.poll.update_counts!
    event = Events::StanceUpdated.publish!(stance)
    MessageChannelService.publish_models([event], scope: {current_user_id: actor.id}, user_id: actor.id)
    event
  end

  def self.redeem(stance:, actor:)
    actor.ability.authorize! :redeem, stance
    stance.update(participant: actor, accepted_at: Time.zone.now)
  end

  # def self.destroy(stance:, actor:)
  #   actor.ability.authorize! :destroy, stance
  #   stance.destroy
  #   EventBus.broadcast 'stance_destroy', stance, actor
  # end
end
