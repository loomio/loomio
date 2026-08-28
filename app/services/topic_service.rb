class TopicService
  class IntegrityError < StandardError; end

  def self.private_default(group_id:)
    group = Group.find_by(id: group_id)
    group ? !group.public_discussions_only? : true
  end

  def self.validate_topicable(topicable)
    topicable_valid = topicable.valid?
    topic_valid = topicable.topic.valid?
    topicable.topic.errors.each do |error|
      topicable.errors.add(error.attribute, error.message)
    end
    topicable_valid && topic_valid
  end

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

      recipient_user_ids = users.pluck(:id)
      stances_by_poll_id = topic.polls.active.where(specified_voters_only: false).each_with_object({}) do |poll, memo|
        memo[poll.id] = PollService.create_anyone_can_vote_stances(poll)
      end

      if topic.topicable_type == "Discussion"
        NotificationService.create!(
          kind: "discussion_announced",
          subject: topic.topicable.created_topic_item,
          actor: actor,
          recipient_user_ids: recipient_user_ids,
          recipient_chatbot_ids: params[:recipient_chatbot_ids],
          recipient_message: params[:recipient_message]
        )
      elsif topic.topicable_type == "Poll"
        PollService.create_poll_announced_notification!(
          poll: topic.topicable,
          actor: actor,
          stances: stances_by_poll_id[topic.topicable_id] || [],
          recipient_user_ids: recipient_user_ids,
          recipient_chatbot_ids: params[:recipient_chatbot_ids],
          recipient_message: params[:recipient_message]
        )
      else
        raise "Cannot announce topicable type #{topic.topicable_type}"
      end
    end
  end

  def self.update(topic:, params:, actor:)
    actor.ability.authorize! :update, topic
    topic.assign_attributes(params)
    rearrange = topic.max_depth_changed?
    return topic unless topic.valid?

    topic.save!
    RepairTopicWorker.perform_later(topic.id) if rearrange
    topic
  end

  def self.update_tags(topic:, tags:, actor:)
    actor.ability.authorize! :update_tags, topic
    TagService.authorize_create_tag_names!(topic.group, tags, actor)
    topic.update!(tags: TagService.clean_tag_names(tags))
  end

  def self.lock(topic:, actor:)
    actor.ability.authorize! :update, topic
    topic.update(locked_at: Time.now, locker_id: actor.id)
    MessageChannelService.publish_models([topic], group_id: topic.group_id, user_id: actor.id)
  end

  def self.unlock(topic:, actor:)
    actor.ability.authorize! :update, topic
    topic.update(locked_at: nil, locker_id: nil)
    MessageChannelService.publish_models([topic], group_id: topic.group_id, user_id: actor.id)
  end

  def self.move(topic:, params:, actor:)
    direct = ActiveModel::Type::Boolean.new.cast(params[:make_direct])
    destination = direct ? NullGroup.new : ModelLocator.new(:group, params).locate!
    destination.present? && actor.ability.authorize!(:move_discussions_to, destination)
    actor.ability.authorize! :move, topic

    Topic.transaction do
      direct_participants_retain!(topic:, actor:) if direct

      topic.update!(group_id: destination.present? ? destination.id : nil,
                    private: moved_discussion_privacy_for(topic, destination))

      # TODO we gotta stop adding group_id to activestorage attachment
      ActiveStorage::Attachment.where(record: topic.items.map(&:itemable).concat([topic])).update_all(group_id: destination.id)

      PollGroupMembersAddedWorker.perform_later(topic.group_id) if topic.group_id
      ReindexDiscussionWorker.perform_later(topic.id)
      TopicItems::DiscussionMoved.create!(
        itemable: topic.topicable,
        user: actor,
        created_at: Time.current
      )
    end
  end

  def self.direct_participant_ids(topic:, actor:)
    direct_participant_ids = topic.items.where.not(user_id: nil).distinct.pluck(:user_id)
    direct_participant_ids.concat(
      topic.polls
        .where(anonymous: false)
        .joins(:stances)
        .merge(Stance.latest.decided)
        .pluck("stances.participant_id")
    )

    topic.items
      .where.not(itemable_type: nil, itemable_id: nil)
      .distinct
      .pluck(:itemable_type, :itemable_id)
      .group_by(&:first)
      .each_value do |itemables|
        direct_participant_ids.concat(
          Reaction.where(
            reactable_type: itemables.first.first,
            reactable_id: itemables.map(&:last)
          ).pluck(:user_id)
        )
      end

    direct_participant_ids
      .concat([actor.id, topic.topicable.author_id])
      .compact
      .uniq
  end

  def self.direct_participants_retain!(topic:, actor:)
    if topic.polls.where(anonymous: true).exists?
      topic.errors.add(:base, I18n.t("errors.direct_thread_anonymous_poll"))
      raise ActiveRecord::RecordInvalid, topic
    end

    direct_participant_ids = direct_participant_ids(topic:, actor:)
    direct_admin_ids = [actor.id, topic.topicable.author_id].compact.uniq
    direct_revoked_at = Time.current

    topic.topic_readers
      .where.not(user_id: direct_participant_ids)
      .update_all(
        admin: false,
        revoked_at: direct_revoked_at,
        revoker_id: actor.id
      )

    direct_participant_ids.each do |user_id|
      reader = TopicReader.for(user: User.find(user_id), topic:)
      reader.assign_attributes(
        admin: direct_admin_ids.include?(user_id),
        guest: true,
        inviter_id: reader.inviter_id || actor.id,
        revoked_at: nil,
        revoker_id: nil
      )
      reader.save!
    end

    topic.update_members_count
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
    RetryOnError.with_limit(2) do
      reader = TopicReader.for(topic: topic, user: actor)
      reader.viewed!([[0, 0]])
      MessageChannelService.publish_models([topic.topicable], group_id: topic.group_id)
      MessageChannelService.publish_models([topic.topicable], user_id: actor.id)
    end
  end

  def self.mark_as_read_simple_params(discussion_id, ranges, actor_id)
    discussion = Discussion.find(discussion_id)
    actor = User.find(actor_id)
    return unless actor.ability.can?(:mark_as_read, discussion.topic)

    mark_as_read(topic: discussion.topic, params: {ranges: ranges}, actor: actor)
  end

  def self.mark_as_read(topic:, params:, actor:)
    actor.ability.authorize! :mark_as_read, topic
    RetryOnError.with_limit(2) do
      sequence_ids = RangeSet.ranges_to_list(RangeSet.to_ranges(params[:ranges]))
      NotificationService.viewed_topic_items(actor_id: actor.id, topic_id: topic.id, sequence_ids: sequence_ids)
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
    discard_without_authorization(topic: topic, actor: actor)
  end

  def self.discard_without_authorization(topic:, actor:)
    topicable = topic.topicable
    discarded_at = Time.current
    Topic.transaction do
      topic.update!(discarded_at: discarded_at, discarded_by: actor.id)
      topicable.update!(discarded_at: discarded_at, discarded_by: actor.id)
      topic.polls.update_all(discarded_at: discarded_at, discarded_by: actor.id)
      ReindexDiscussionWorker.perform_later(topicable.id) if topicable.is_a?(Discussion)
    end
    EventBus.broadcast('discussion_discard', topicable, actor) if topicable.is_a?(Discussion)
    topicable
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

    TopicQuery.relevant_to(user: user, only_unread: true, or_subgroups: false)
      .where("topics.last_activity_at > ?", time_start).each do |topic|
      RetryOnError.with_limit(2) do
        sequence_ids = topic.items.where("topic_items.created_at": time_range).pluck(:sequence_id)
        TopicReader.for(user: user, topic: topic).viewed!(sequence_ids)
      end
    end
  end

  def self.legacy_misordered_poll_created_topic_ids
    TopicItem
      .joins("INNER JOIN topic_items later_comments ON later_comments.topic_id = topic_items.topic_id")
      .where("topic_items.kind = ?", 'poll_created')
      .where("later_comments.kind = ?", 'new_comment')
      .where("topic_items.topic_id IS NOT NULL")
      .where("topic_items.sequence_id > later_comments.sequence_id")
      .where("topic_items.created_at < later_comments.created_at")
      .distinct
      .pluck(:topic_id)
  end

  def self.enqueue_legacy_poll_created_resequence
    legacy_misordered_poll_created_topic_ids.tap do |topic_ids|
      topic_ids.each do |topic_id|
        ResequenceLegacyPollCreatedTopicWorker.perform_later(topic_id)
      end
    end.length
  end

  def self.resequence_chronologically(topic_id)
    topic = Topic.find_by(id: topic_id)
    return unless topic

    repair(topic.id)
    topic.reload

    root_topic_item = topic.topicable.created_topic_item
    return unless root_topic_item

    topic_item_ids = TopicItem.where(topic_id: topic.id)
                     .where.not(id: root_topic_item.id)
                     .order(:created_at, :id)
                     .pluck(:id)

    TopicItem.where(topic_id: topic.id).update_all(sequence_id: nil, position: 0, position_key: nil)
    TopicItem.where(id: root_topic_item.id).update_all(sequence_id: 0, position: 0, depth: 0, parent_id: nil, position_key: '00000', topic_id: topic.id)

    topic_item_ids.each.with_index(1) do |topic_item_id, sequence_id|
      TopicItem.where(id: topic_item_id).update_all(sequence_id: sequence_id)
    end

    repair(topic.id)
  end

  def self.repair(topic_id)
    topic = Topic.find_by(id: topic_id)
    return unless topic
    topicable = topic.topicable
    return unless topicable

    # ensure topicable.created_topic_item exists
    unless topicable.created_topic_item
      TopicItem.import [TopicItem.new(kind: topicable.created_topic_item_kind.to_s,
                              user_id: topicable.author_id,
                              topic_id: topic.id,
                              itemable_id: topicable.id,
                              itemable_type: topicable.class.name,
                              created_at: topicable.created_at)]
      topicable.reload
    end

    created_topic_item = topicable.created_topic_item
    duplicate_created_topic_items = TopicItem.where(
      itemable: topicable,
      kind: topicable.created_topic_item_kind.to_s,
      topic_id: topic.id
    )
                                    .where.not(id: created_topic_item.id)
    TopicItem.where(parent_id: duplicate_created_topic_items.select(:id)).update_all(parent_id: created_topic_item.id)
    duplicate_created_topic_items.destroy_all
    TopicItem.where(topic_id: topic.id, sequence_id: 0).where.not(id: created_topic_item.id).update_all(sequence_id: nil, position: 0, position_key: nil)
    created_topic_item.update_columns(sequence_id: 0, position: 0, depth: 0, parent_id: nil, position_key: '00000', topic_id: topic.id)

    TopicItem.where(topic_id: topic.id, sequence_id: nil).where.not(id: created_topic_item.id).order(:id).each(&:set_sequence_id!)

    # rebuild ancestry of topic_items based on itemable relationships
    items = TopicItem.where(topic_id: topic.id).where.not(id: created_topic_item.id).order(:sequence_id)
    items.update_all(parent_id: created_topic_item.id, position: 0, position_key: nil, depth: 1)
    items.reload.compact.each(&:set_parent_and_depth!)

    parent_ids = items.pluck(:parent_id).compact.uniq

    reset_child_positions(created_topic_item.id, "00000")
    TopicItem.where(id: parent_ids).order(:depth).each do |parent_topic_item|
      parent_topic_item.reload
      reset_child_positions(parent_topic_item.id, parent_topic_item.position_key)
    end

    ActiveRecord::Base.connection.execute(
      "UPDATE topic_items
       SET child_count = (
        SELECT count(children.id) FROM topic_items children
        WHERE children.parent_id = topic_items.id
      )
      WHERE topic_id = #{topic.id.to_i}")

    created_topic_item.reload.update_columns(
      child_count: created_topic_item.children.count
    )
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

  def self.verify_integrity!(topic_id)
    topic_items = TopicItem.where(topic_id: topic_id).to_a
    topic_items_by_id = topic_items.index_by(&:id)
    child_counts = topic_items.group_by(&:parent_id).transform_values(&:length)
    failures = []

    topic_items.each do |topic_item|
      expected_child_count = child_counts.fetch(topic_item.id, 0)
      failures << "topic_item #{topic_item.id} child_count" unless topic_item.child_count == expected_child_count
      failures << "topic_item #{topic_item.id} sequence_id" if topic_item.sequence_id.nil?
      failures << "topic_item #{topic_item.id} position" if topic_item.position.nil?
      failures << "topic_item #{topic_item.id} position_key" if topic_item.position_key.blank?

      if topic_item.parent_id
        parent = topic_items_by_id[topic_item.parent_id]
        failures << "topic_item #{topic_item.id} parent" unless parent
        failures << "topic_item #{topic_item.id} depth" if parent && topic_item.depth != parent.depth + 1
        failures << "topic_item #{topic_item.id} position ancestry" if parent && !topic_item.position_key.to_s.start_with?("#{parent.position_key}-")
      end
    end

    return if failures.empty?

    raise IntegrityError, "Topic #{topic_id} repair failed: #{failures.join(', ')}"
  end

  def self.reset_child_positions(parent_id, parent_position_key)
    parent_id = parent_id.to_i
    position_key_sql = if parent_position_key.nil?
      "CONCAT(REPEAT('0',5-LENGTH(CONCAT(t.seq))), t.seq)"
    else
      quoted_prefix = ActiveRecord::Base.connection.quote("#{parent_position_key}-")
      "CONCAT(#{quoted_prefix}, CONCAT(REPEAT('0',5-LENGTH(CONCAT(t.seq) ) ), t.seq) )"
    end
    ActiveRecord::Base.connection.execute(
      "UPDATE topic_items SET position = t.seq, position_key = #{position_key_sql}
        FROM (
          SELECT id AS id, row_number() OVER(ORDER BY sequence_id) AS seq
          FROM topic_items
          WHERE parent_id = #{parent_id}
        ) AS t
      WHERE topic_items.id = t.id and
            topic_items.position is distinct from t.seq")
    SequenceService.drop_seq!('events_position', parent_id)
  end

  def self.repair_all
    Topic.pluck(:id).each do |id|
      RepairTopicWorker.perform_later(id)
    end
  end

  def self.extract_link_preview_urls(topic)
    urls = topic.topicable.respond_to?(:link_previews) ? topic.topicable.link_previews.map { |lp| lp['url'] } : []
    topic.items.each do |topic_item|
      if topic_item.itemable.present? && topic_item.itemable.respond_to?(:link_previews)
        urls.concat(topic_item.itemable.link_previews.map {|lp| lp['url']})
      end
    end
    urls.compact.uniq
  end

  def self.add_users(topic:, actor:, user_ids:, emails:, audience:)
    users = UserInviter.where_or_create!(actor: actor,
                                         user_ids: user_ids,
                                         emails: emails,
                                         model: topic,
                                         audience: audience)

    volumes = {}

    if topic.group_id
      Membership.active.where(group_id: topic.group_id,
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
                      admin: false,
                      volume: volumes[user.id] || user.default_membership_volume)
    end

    TopicReader.import(new_topic_readers, on_duplicate_key_ignore: true)

    topic.update_members_count
    users
  end
end
