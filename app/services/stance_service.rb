class StanceService
  def self.create(stance:, actor:)
    actor.ability.authorize!(:vote_in, stance.poll)

    stance.participant = actor
    stance.cast_at ||= Time.zone.now
    stance.revoked_at = nil
    stance.revoker_id = nil
    event = Stance.transaction do
      stance.save!
      stance.poll.update_counts!
      Events::StanceCreated.publish!(stance)
    end

    Sentry.metrics.count("stance.create", attributes: { poll_type: stance.poll.poll_type })
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
    params = params.to_h.with_indifferent_access.except(:poll_id)
    is_update = !!stance.cast_at

    new_stance = stance.build_replacement
    new_stance.assign_attributes_and_files(params)

    event = Event.where(eventable: stance, topic_id: stance.poll.topic&.id).order('id desc').first

    stance_to_publish = nil
    metric_name = nil
    result = Stance.transaction do
      if is_update && stance.option_scores != new_stance.build_option_scores && (Comment.kept.where(parent: stance).exists? ||  stance.updated_at < 15.minutes.ago)
        # they've changed their position, and someone has replied to them or it's been a while and people will have seeen their position

        new_stance.cast_at = Time.zone.now
        stance.update_columns(latest: false)
        new_stance.save!
        new_stance.poll.update_counts!
        stance_to_publish = stance if stance.shared_update_visible?
        metric_name = "stance.update"
        Events::StanceCreated.publish!(new_stance)
      else
        stance.stance_choices = []
        stance.assign_attributes_and_files(params)
        stance.cast_at ||= Time.zone.now
        stance.revoked_at = nil
        stance.revoker_id = nil
        stance.save!
        stance.poll.update_counts!
        metric_name = is_update ? "stance.update" : "stance.create"
        is_update ? Events::StanceUpdated.publish!(stance) : Events::StanceCreated.publish!(stance)
      end
    end

    if stance_to_publish
      MessageChannelService.publish_models([stance_to_publish], group_id: stance.poll.group_id)
    end
    Sentry.metrics.count(metric_name, attributes: { poll_type: stance.poll.poll_type })
    result
  end

  def self.redeem(stance:, actor:)
    return if Stance.latest.where(participant_id: actor.id, poll_id: stance.poll_id).exists?
    return unless Stance.redeemable_by(actor).where(id: stance.id).exists?
    stance.update(participant: actor, accepted_at: Time.zone.now)
  end

  def self.redact(stance:, actor:)
    actor.ability.authorize!(:redact, stance)
    stance.update!(redacted_at: Time.zone.now, redactor_id: actor.id)
    stance.update_pg_search_document
    if stance.shared_update_visible?
      MessageChannelService.publish_models([stance], group_id: stance.poll.group_id, topic_id: stance.poll.topic_id)
    end
  end

  def self.unredact(stance:, actor:)
    actor.ability.authorize!(:unredact, stance)
    stance.update!(redacted_at: nil, redactor_id: nil)
    stance.update_pg_search_document
    if stance.shared_update_visible?
      MessageChannelService.publish_models([stance], group_id: stance.poll.group_id, topic_id: stance.poll.topic_id)
    end
  end

  # def self.destroy(stance:, actor:)
  #   actor.ability.authorize! :destroy, stance
  #   stance.destroy
  #   EventBus.broadcast 'stance_destroy', stance, actor
  # end
end
