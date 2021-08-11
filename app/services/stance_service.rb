class StanceService
  def self.redeem(stance:, actor:)
    actor.ability.authorize! :redeem, stance
    stance.update(participant: actor, accepted_at: Time.zone.now)
  end

  # def self.destroy(stance:, actor:)
  #   actor.ability.authorize! :destroy, stance
  #   stance.destroy
  #   EventBus.broadcast 'stance_destroy', stance, actor
  # end

  # is used for both create and update
  # I deeply apologise for how this method could take a stance from 3 places.
  def self.create(stance:, actor:, params: {}, force_create: false)

    stance = Stance.where(
      poll_id: stance.poll_id,
      participant_id: actor.id,
      latest: true).first || stance unless force_create

    actor.ability.authorize! :vote_in, stance.poll

    if params.keys.any?
      stance.stance_choices.clear
      stance.assign_attributes_and_files(params)
    end

    actor.ability.authorize! :vote_in, stance.poll

    return false unless stance.valid?

    stance.participant = actor
    stance.cast_at ||= Time.zone.now

    Stance.transaction do
      Stance.where(poll: stance.poll_id, participant_id: actor.id).
             where.not(id: stance.id).
             update_all(latest: false)
      stance.save!
    end

    stance.poll.update_counts!

    event = if stance.created_event
      Events::StanceUpdated.publish!(stance)
    else
      Events::StanceCreated.publish!(stance)
    end

    MessageChannelService.publish_models([event], scope: {current_user_id: actor.id}, user_id: actor.id)
    event
  end
end
