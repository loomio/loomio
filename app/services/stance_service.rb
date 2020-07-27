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

  def self.create(stance:, actor:)
    actor.ability.authorize! :create, stance

    stance.assign_attributes(participant: actor)
    stance.cast_at = Time.zone.now

    return false unless stance.valid?

    stance.poll.stances.where(participant: actor).update_all(latest: false)
    stance.update_attachments!
    stance.save!
    stance.poll.update_stance_data
    EventBus.broadcast 'stance_create', stance
    Events::StanceCreated.publish! stance
  end

  def self.update(stance:, actor:, params:)
    actor.ability.authorize! :update, stance
    stance.stance_choices.delete_all
    HasRichText.assign_attributes_and_update_files(stance, params)
    return false unless stance.valid?
    stance.update_attachments!
    stance.save!
    stance.poll.update_stance_data

    EventBus.broadcast 'stance_update', stance, actor
  end
end
