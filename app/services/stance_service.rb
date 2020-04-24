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

    actor = actor.create_user if !actor.is_logged_in?

    stance.assign_attributes(participant: actor)
    stance.cast_at = Time.zone.now
    return false unless stance.valid?

    stance.poll.stances.where(participant: actor).update_all(latest: false)
    stance.update_attachments!
    stance.save!
    stance.participant.save!
    EventBus.broadcast 'stance_create', stance, actor
    Events::StanceCreated.publish! stance
  end

  def self.update(stance:, actor:, params:)
    actor.ability.authorize! :update, stance
    HasRichText.assign_attributes_and_update_files(stance, params)
    return false unless stance.valid?
    stance.update_attachments!
    stance.save!

    EventBus.broadcast 'stance_update', stance, actor
  end
end
