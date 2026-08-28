class StanceService
  def self.create(stance:, actor:, &on_topic_item)
    actor.ability.authorize!(:vote_in, stance.poll)

    stance.participant = actor
    stance.cast_at ||= Time.zone.now
    stance.revoked_at = nil
    stance.revoker_id = nil
    return stance unless stance.valid?

    publication = Stance.transaction do
      stance.save!
      stance.poll.update_counts!
      publish_stance_change!(stance: stance, kind: "stance_created")
    end

    publish_stance_directly!(stance, publication)
    Sentry.metrics.count("stance.create", attributes: { poll_type: stance.poll.poll_type })
    on_topic_item&.call(publication[:topic_item]) if publication[:topic_item]
    stance
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

  def self.update(stance: , actor: , params: , &on_topic_item)
    actor.ability.authorize!(:update, stance)
    params = params.to_h.with_indifferent_access.except(:poll_id)
    is_update = !!stance.cast_at

    new_stance = stance.build_replacement
    new_stance.assign_attributes_and_files(params)

    creates_replacement = is_update && stance.option_scores != new_stance.build_option_scores && (Comment.kept.where(parent: stance).exists? || stance.updated_at < 15.minutes.ago)
    stance_changed = creates_replacement ? new_stance : stance
    unless creates_replacement
      stance.stance_choices = []
      stance.assign_attributes_and_files(params)
      stance.cast_at ||= Time.zone.now
      stance.revoked_at = nil
      stance.revoker_id = nil
    end
    return stance_changed unless stance_changed.valid?

    stance_to_publish = nil
    metric_name = nil
    publication = Stance.transaction do
      if creates_replacement
        # they've changed their position, and someone has replied to them or it's been a while and people will have seeen their position

        new_stance.cast_at = Time.zone.now
        stance.update_columns(latest: false)
        new_stance.save!
        new_stance.poll.update_counts!
        stance_to_publish = stance if stance.shared_update_visible?
        stance_changed = new_stance
        metric_name = "stance.update"
        publish_stance_change!(stance: new_stance, kind: "stance_created")
      else
        stance.save!
        stance.poll.update_counts!
        stance_changed = stance
        metric_name = is_update ? "stance.update" : "stance.create"
        publish_stance_change!(
          stance: stance,
          kind: is_update ? "stance_updated" : "stance_created"
        )
      end
    end

    if stance_to_publish
      MessageChannelService.publish_models([stance_to_publish], group_id: stance.poll.group_id)
    end
    publish_stance_directly!(stance_changed, publication)
    Sentry.metrics.count(metric_name, attributes: { poll_type: stance.poll.poll_type })
    on_topic_item&.call(publication[:topic_item]) if publication[:topic_item]
    stance_changed
  end

  def self.redeem(stance:, actor:)
    return if Stance.latest.where(participant_id: actor.id, poll_id: stance.poll_id).exists?
    return unless Stance.redeemable_by(actor).where(id: stance.id).exists?
    stance.update(participant: actor, accepted_at: Time.zone.now)
  end

  # Create a topic item only when the response belongs in the timeline. Direct
  # mention notifications share the transaction, while subscriber delivery and
  # chatbot publication remain responsibilities of the topic item itself.
  def self.publish_stance_change!(stance:, kind:)
    topic_item_class = kind == "stance_created" ? TopicItems::StanceCreated : TopicItems::StanceUpdated
    was_shared_update_visible = stance.shared_update_visible?
    MarkNotificationsAsReadWorker.perform_later("Poll", stance.poll_id, stance.participant_id)
    if stance.add_to_thread?
      topic_item = topic_item_class.create!(itemable: stance)
    end
    MentionNotificationService.create!(
      subject: topic_item || stance,
      actor: stance.participant,
      notify: was_shared_update_visible
    )
    { topic_item: topic_item, was_shared_update_visible: was_shared_update_visible }
  end
  private_class_method :publish_stance_change!

  def self.publish_stance_directly!(stance, publication)
    return if publication[:topic_item]
    return unless publication[:was_shared_update_visible]

    MessageChannelService.publish_topic_model(stance)
  end
  private_class_method :publish_stance_directly!

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
