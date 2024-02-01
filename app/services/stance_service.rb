class StanceService
  def self.create(stance:, actor:)
    actor.ability.authorize!(:vote_in, stance.poll)

    stance.participant = actor
    stance.cast_at ||= Time.zone.now
    stance.revoked_at = nil
    stance.revoker_id = nil
    stance.save!
    stance.poll.update_counts!

    event = Events::StanceCreated.publish!(stance)
    event
  end

  def self.uncast(stance:, actor:)
    actor.ability.authorize!(:uncast, stance)

    new_stance = stance.build_replacement
    Stance.transaction do
      stance.update_columns(latest: false)
      new_stance.save!
    end

    new_stance.poll.update_counts!
  end

  def self.update(stance: , actor: , params: ) 
    actor.ability.authorize!(:update, stance)
    is_update = !!stance.cast_at

    new_stance = stance.build_replacement
    new_stance.assign_attributes_and_files(params)

    event = Event.where(eventable: stance, discussion_id: stance.poll.discussion_id).order('id desc').first
    if is_update && stance.option_scores != new_stance.build_option_scores && event && event.child_count > 0
      # they've changed their position and there were replies! create a new stance, so that discussion threads make sense

      new_stance.cast_at = Time.zone.now

      Stance.transaction do
        stance.update_columns(latest: false)
        new_stance.save!
      end

      new_stance.poll.update_counts!
      MessageChannelService.publish_models([stance], group_id: stance.poll.group_id)
      Events::StanceCreated.publish!(new_stance)
    else
      stance.stance_choices = []
      stance.assign_attributes_and_files(params)
      stance.cast_at ||= Time.zone.now
      stance.revoked_at = nil
      stance.revoker_id = nil
      stance.save!
      stance.poll.update_counts!
      if is_update
        Events::StanceUpdated.publish!(stance)
      else
        Events::StanceCreated.publish!(stance)
      end
    end
  end

  def self.redeem(stance:, actor:)
    return if Stance.latest.where(participant_id: actor.id, poll_id: stance.poll_id).exists?
    return unless Stance.redeemable_by(actor).where(id: stance.id).exists?
    stance.update(participant: actor, accepted_at: Time.zone.now)
  end

  # def self.destroy(stance:, actor:)
  #   actor.ability.authorize! :destroy, stance
  #   stance.destroy
  #   EventBus.broadcast 'stance_destroy', stance, actor
  # end
end
