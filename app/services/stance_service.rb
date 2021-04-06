class StanceService
  def self.redeem(stance:, actor:)
    actor.ability.authorize! :redeem, stance
    stance.update(participant: actor, accepted_at: Time.zone.now)
  end

  def self.destroy(stance:, actor:)
    actor.ability.authorize! :destroy, stance
    stance.destroy
    EventBus.broadcast 'stance_destroy', stance, actor
  end

  # is used for both create and update
  def self.create(stance:, actor:, params: {}, force_create: false)

    stance = Stance.where(
      poll_id: stance.poll_id,
      participant_id: actor.id,
      latest: true).first || stance unless force_create

    actor.ability.authorize! :vote_in, stance.poll

    if params.keys.any?
      params.delete(:poll_id) if stance.poll.present?
      stance.stance_choices.clear
      stance.assign_attributes_and_files(params)
    end

    return false unless stance.valid?

    stance.participant = actor
    stance.cast_at ||= Time.zone.now

    Stance.transaction do
      Stance.where(poll: stance.poll_id, participant_id: actor.id).
             where.not(id: stance.id).
             update_all(latest: false)
      stance.save!
    end

    stance.update_versions_count
    stance.poll.update_stance_data

    event = stance.created_event || Events::StanceCreated.publish!(stance)
    MessageChannelService.publish_models([event], scope: {current_user_id: actor.id}, user_id: actor.id)
    EventBus.broadcast('stance_create', stance, actor)
    event
  end
end
