class TopicService
  def self.invite(topic:, actor:, params:)
    UserInviter.authorize!(user_ids: params[:recipient_user_ids],
                           emails: params[:recipient_emails],
                           audience: params[:recipient_audience],
                           model: topic,
                           actor: actor)

    Topic.transaction do
      users = add_users(topic: topic,
                        actor: actor,
                        user_ids: params[:recipient_user_ids],
                        emails: params[:recipient_emails],
                        audience: params[:recipient_audience])

      topic.polls.active.where(specified_voters_only: false).each do |poll|
        PollService.create_anyone_can_vote_stances(poll)
      end

      if topic.topicable_type == "Discussion"
        Events::DiscussionAnnounced.publish!(discussion: topic.topicable,
                                             actor: actor,
                                             recipient_user_ids: users.pluck(:id),
                                             recipient_chatbot_ids: params[:recipient_chatbot_ids],
                                             recipient_audience: params[:recipient_audience],
                                             recipient_message: params[:recipient_message])
      else
        raise "gotta finish this bit"
      end
    end
  end

  def self.update(topic:, params:, actor:)
    actor.ability.authorize! :update, topic
    topic.assign_attributes(params)
    rearrange = topic.max_depth_changed?
    topic.save!
    RepairThreadWorker.perform_async(topic.id) if rearrange
  end

  def self.close(topic:, actor:)
    actor.ability.authorize! :update, topic
    topic.update(closed_at: Time.now, closer_id: actor.id)
    MessageChannelService.publish_models([topic], group_id: topic.group_id, user_id: actor.id)
  end

  def self.reopen(topic:, actor:)
    actor.ability.authorize! :update, topic
    topic.update(closed_at: nil, closer_id: nil)
    MessageChannelService.publish_models([topic], group_id: topic.group_id, user_id: actor.id)
  end

  def self.move(topic:, params:, actor:)
    source = topic.group
    destination = ModelLocator.new(:group, params).locate || NullGroup.new
    destination.present? && actor.ability.authorize!(:move_discussions_to, destination)
    actor.ability.authorize! :move, topic

    Topic.transaction do
      topic.update!(group_id: destination.present? ? destination.id : nil,
                    private: moved_discussion_privacy_for(topic, destination))

      # TODO we gotta stop adding group_id to activestorage attachment
      ActiveStorage::Attachment.where(record: topic.items.map(&:eventable).concat([topic])).update_all(group_id: destination.id)

      GenericWorker.perform_async('PollService', 'group_members_added', topic.group_id) if topic.group_id
      GenericWorker.perform_async('SearchService', 'reindex_by_discussion_id', topic.id)
      Events::DiscussionMoved.publish!(topic.topicable, actor, source)
    end
  end

  def self.pin(topic:, actor:)
    actor.ability.authorize! :pin, topic
    topic.update(pinned_at: Time.now)
  end

  def self.unpin(topic:, actor:)
    actor.ability.authorize! :pin, topic
    topic.update(pinned_at: nil)
  end

  def self.update_reader(topic:, params:, actor:)
    actor.ability.authorize! :show, topic
    reader = TopicReader.for(topic: topic, user: actor)
    reader.update(params.slice(:volume))
  end

  def self.mark_as_seen(topic:, actor:)
    actor.ability.authorize! :mark_as_seen, topic
    reader = TopicReader.for(topic: topic, user: actor)
    reader.viewed!
    MessageChannelService.publish_models([topic.topicable], group_id: topic.group_id)
    MessageChannelService.publish_models([topic.topicable], user_id: actor.id)
  end

  def self.mark_as_read_simple_params(discussion_id, ranges, actor_id)
    discussion = Discussion.find(discussion_id)
    actor = User.find(actor_id)
    mark_as_read(topic: discussion.topic, params: {ranges: ranges}, actor: actor)
  end

  def self.mark_as_read(topic:, params:, actor:)
    return unless actor.ability.can?(:mark_as_read, topic)
    RetryOnError.with_limit(2) do
      sequence_ids = RangeSet.ranges_to_list(RangeSet.to_ranges(params[:ranges]))
      NotificationService.viewed_events(actor_id: actor.id, topic_id: topic.id, sequence_ids: sequence_ids)
      reader = TopicReader.for(topic: topic, user: actor)
      reader.viewed!(params[:ranges])
      MessageChannelService.publish_models([topic.topicable], group_id: topic.group_id)
      MessageChannelService.publish_models([topic.topicable], user_id: actor.id)
    end
  end

  def self.dismiss(topic:, actor:, params: {})
    actor.ability.authorize! :dismiss, topic
    reader = TopicReader.for(user: actor, topic: topic)
    reader.dismiss!
    EventBus.broadcast('discussion_dismiss', reader, actor)
  end

  def self.recall(topic:, actor:, params: {})
    actor.ability.authorize! :dismiss, topic
    reader = TopicReader.for(user: actor, topic: topic)
    reader.recall!
    EventBus.broadcast('discussion_recall', reader, actor)
  end

  def self.discard(topic:, actor:)
    actor.ability.authorize! :discard, topic
    topicable = topic.topicable
    Topic.transaction do
      topicable.update(discarded_at: Time.now, discarded_by: actor.id)
      topic.polls.update_all(discarded_at: Time.now, discarded_by: actor.id)
      GenericWorker.perform_async('SearchService', 'reindex_by_discussion_id', topicable.id) if topicable.is_a?(Discussion)
      EventBus.broadcast('discussion_discard', topicable, actor) if topicable.is_a?(Discussion)
    end
  end

  def self.moved_discussion_privacy_for(topic, destination)
    case destination.discussion_privacy_options
    when 'public_only'  then false
    when 'private_only' then true
    else                     topic.private
    end
  end

  def self.mark_summary_email_as_read(user_id, time_start_i, time_finish_i)
    user = User.find_by!(id: user_id)
    time_start  = Time.at(time_start_i).utc
    time_finish = Time.at(time_finish_i).utc
    time_range = time_start..time_finish

    DiscussionQuery.visible_to(user: user, only_unread: true, or_public: false, or_subgroups: false).last_activity_after(time_start).each do |discussion|
      RetryOnError.with_limit(2) do
        sequence_ids = discussion.items.where("events.created_at": time_range).pluck(:sequence_id)
        TopicReader.for(user: user, topic: discussion.topic).viewed!(sequence_ids)
      end
    end
  end

  def self.repair_thread(topic_id)
    topic = Topic.find_by(id: topic_id)
    return unless topic
    topicable = topic.topicable

    # ensure topicable.created_event exists
    unless topicable.created_event
      Event.import [Event.new(kind: topicable.created_event_kind.to_s,
                              user_id: topicable.author_id,
                              eventable_id: topicable.id,
                              eventable_type: topicable.class.name,
                              created_at: topicable.created_at)]
      topicable.reload
    end

    created_event = topicable.created_event
    Event.where(topic_id: topic.id, sequence_id: nil).where.not(id: created_event.id).order(:id).each(&:set_sequence_id!)

    # rebuild ancestry of events based on eventable relationships
    items = Event.where(topic_id: topic.id).where.not(id: created_event.id).order(:sequence_id)
    items.update_all(parent_id: created_event.id, position: 0, position_key: nil, depth: 1)
    items.reload.compact.each(&:set_parent_and_depth!)

    parent_ids = items.pluck(:parent_id).compact.uniq

    reset_child_positions(created_event.id, nil)
    Event.where(id: parent_ids).order(:depth).each do |parent_event|
      parent_event.reload
      reset_child_positions(parent_event.id, parent_event.position_key)
    end

    ActiveRecord::Base.connection.execute(
      "UPDATE events
       SET descendant_count = (
         SELECT count(descendants.id)
         FROM events descendants
         WHERE
            descendants.topic_id = events.topic_id AND
            descendants.id != events.id AND
            descendants.position_key like CONCAT(events.position_key, '%')
      ), child_count = (
        SELECT count(children.id) FROM events children
        WHERE children.parent_id = events.id AND children.topic_id IS NOT NULL
      )
      WHERE topic_id = #{topic.id.to_i}")

    created_event.reload.update_child_count
    created_event.update_descendant_count
    topic.update_sequence_info!

    # ensure all the topic_readers have valid read_ranges values
    TopicReader.where(topic_id: topic.id).each do |reader|
      reader.update_columns(
        read_ranges_string: RangeSet.serialize(
          RangeSet.intersect_ranges(reader.read_ranges, topic.ranges)
        )
      )
    end
  end

  def self.reset_child_positions(parent_id, parent_position_key)
    position_key_sql = if parent_position_key.nil?
      "CONCAT(REPEAT('0',5-LENGTH(CONCAT(t.seq))), t.seq)"
    else
      "CONCAT('#{parent_position_key}-', CONCAT(REPEAT('0',5-LENGTH(CONCAT(t.seq) ) ), t.seq) )"
    end
    ActiveRecord::Base.connection.execute(
      "UPDATE events SET position = t.seq, position_key = #{position_key_sql}
        FROM (
          SELECT id AS id, row_number() OVER(ORDER BY sequence_id) AS seq
          FROM events
          WHERE parent_id = #{parent_id}
          AND   topic_id IS NOT NULL
        ) AS t
      WHERE events.id = t.id and
            events.position is distinct from t.seq")
    SequenceService.drop_seq!('events_position', parent_id)
  end

  def self.repair_all_threads
    Topic.pluck(:id).each do |id|
      RepairThreadWorker.perform_async(id)
    end
  end

  def self.add_users(topic:, actor:, user_ids:, emails:, audience:)
    users = UserInviter.where_or_create!(actor: actor,
                                         user_ids: user_ids,
                                         emails: emails,
                                         model: topic,
                                         audience: audience)

    volumes = {}

    if topic.group_id
      Membership.where(group_id: topic.group_id,
                      user_id: users.pluck(:id)).find_each do |m|
        volumes[m.user_id] = m.volume
      end
    end

    TopicReader.
      where(topic_id: topic.id, user_id: users.map(&:id)).
      where("revoked_at is not null").update_all(revoked_at: nil, revoker_id: nil)

    new_topic_readers = users.map do |user|
      TopicReader.new(user: user,
                      topic: topic,
                      inviter: actor,
                      guest: !volumes.has_key?(user.id),
                      admin: !topic.group_id,
                      volume: volumes[user.id] || user.default_membership_volume)
    end

    TopicReader.import(new_topic_readers, on_duplicate_key_ignore: true)

    topic.update_members_count
    users
  end
end
