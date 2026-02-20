class TopicService
  def self.invite(topic:, actor:, params:)
    UserInviter.authorize!(user_ids: params[:recipient_user_ids],
                           emails: params[:recipient_emails],
                           audience: params[:recipient_audience],
                           model: topic,
                           actor: actor)

    Topic.transaction do
      users = add_users(topic: discussion,
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
      Events::TopicMoved.publish!(topic, actor, source)
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
    MessageChannelService.publish_models([toipc.topicable], user_id: actor.id)
  end

  def self.mark_as_read_simple_params(discussion_id, ranges, actor_id)
    discussion = Discussion.find(discussion_id)
    actor = User.find(actor_id)
    mark_as_read(discussion: discussion, params: {ranges: ranges}, actor: actor)
  end

  def self.mark_as_read(topic:, params:, actor:)
    return unless actor.ability.can?(:mark_as_read, topic)
    RetryOnError.with_limit(2) do
      sequence_ids = RangeSet.ranges_to_list(RangeSet.to_ranges(params[:ranges]))
      NotificationService.viewed_events(actor_id: actor.id, topic_id: topic.id, sequence_ids: sequence_ids)
      reader = TopicReader.for(topic: topic, user: actor)
      reader.viewed!(params[:ranges])
      MessageChannelService.publish_models([topicable], group_id: topic.group_id)
      MessageChannelService.publish_models([topicable], user_id: actor.id)
    end
  end

  def self.dismiss(discussion:, params:, actor:)
    actor.ability.authorize! :dismiss, discussion
    reader = TopicReader.for(user: actor, topic: discussion.topic)
    reader.dismiss!
    EventBus.broadcast('discussion_dismiss', reader, actor)
  end

  def self.recall(discussion:, params:, actor:)
    actor.ability.authorize! :dismiss, discussion
    reader = TopicReader.for(user: actor, topic: discussion.topic)
    reader.recall!
    EventBus.broadcast('discussion_recall', reader, actor)
  end

  def self.moved_discussion_privacy_for(discussion, destination)
    case destination.discussion_privacy_options
    when 'public_only'  then false
    when 'private_only' then true
    else                     discussion.topic.private
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

  def self.add_users(topic:, actor:, user_ids:, emails:, audience:)
    users = UserInviter.where_or_create!(actor: actor,
                                         user_ids: user_ids,
                                         emails: emails,
                                         model: topic,
                                         audience: audience)

    volumes = {}
    Membership.where(group_id: topic.group_id,
                     user_id: users.pluck(:id)).find_each do |m|
      volumes[m.user_id] = m.volume
    end

    TopicReader.
      where(topic_id: topic.id, user_id: users.map(&:id)).
      where("revoked_at is not null").update_all(revoked_at: nil, revoker_id: nil)

    new_topic_readers = users.map do |user|
      TopicReader.new(user: user,
                      topic: topic,
                      inviter: actor,
                      guest: !volumes.has_key?(user.id),
                      admin: !discussion.group_id,
                      volume: volumes[user.id] || user.default_membership_volume)
    end

    TopicReader.import(new_topic_readers, on_duplicate_key_ignore: true)

    topic.update_members_count
    users
  end
end
