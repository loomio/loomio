class DiscussionService
  def self.create(discussion:, actor:, params: {})
    actor.ability.authorize!(:create, discussion)

    UserInviter.authorize!(user_ids: params[:recipient_user_ids],
                           emails: params[:recipient_emails],
                           audience: params[:recipient_audience],
                           model: discussion,
                           actor: actor)

    discussion.author = actor

    return false unless discussion.valid?

    discussion.save!

    DiscussionReader.for(user: actor, discussion: discussion)
                    .update(admin: true, inviter_id: actor.id)

    users = add_users(user_ids: params[:recipient_user_ids],
                      emails: params[:recipient_emails],
                      audience: params[:recipient_audience],
                      discussion: discussion,
                      actor: actor)

    EventBus.broadcast('discussion_create', discussion, actor)
    Events::NewDiscussion.publish!(discussion: discussion,
                                   recipient_user_ids: users.pluck(:id),
                                   recipient_chatbot_ids: params[:recipient_chatbot_ids],
                                   recipient_audience: params[:recipient_audience])

  end

  def self.update(discussion:, actor:, params:)
    actor.ability.authorize! :update, discussion

    UserInviter.authorize!(user_ids: params[:recipient_user_ids],
                           emails: params[:recipient_emails],
                           audience: params[:recipient_audience],
                           model: discussion,
                           actor: actor)


    discussion.assign_attributes_and_files(params.except(:group_id))
    return false unless discussion.valid?
    rearrange = discussion.max_depth_changed?
    discussion.save!

    discussion.update_versions_count
    RepairThreadWorker.perform_async(discussion.id) if rearrange

    users = add_users(discussion: discussion,
                      actor: actor,
                      user_ids: params[:recipient_user_ids],
                      emails: params[:recipient_emails],
                      audience: params[:recipient_audience])

    EventBus.broadcast('discussion_update', discussion, actor, params)

    Events::DiscussionEdited.publish!(discussion: discussion,
                                      actor: actor,
                                      recipient_user_ids: users.pluck(:id),
                                      recipient_chatbot_ids: params[:recipient_chatbot_ids],
                                      recipient_audience: params[:recipient_audience],
                                      recipient_message: params[:recipient_message])
  end

  def self.invite(discussion:, actor:, params:)
    UserInviter.authorize!(user_ids: params[:recipient_user_ids],
                           emails: params[:recipient_emails],
                           audience: params[:recipient_audience],
                           model: discussion,
                           actor: actor)

    users = add_users(discussion: discussion,
                      actor: actor,
                      user_ids: params[:recipient_user_ids],
                      emails: params[:recipient_emails],
                      audience: params[:recipient_audience])

    Events::DiscussionAnnounced.publish!(discussion: discussion,
                                         actor: actor,
                                         recipient_user_ids: users.pluck(:id),
                                         recipient_chatbot_ids: params[:recipient_chatbot_ids],
                                         recipient_audience: params[:recipient_audience],
                                         recipient_message: params[:recipient_message])
  end

  # def self.destroy(discussion:, actor:)
  #   actor.ability.authorize!(:destroy, discussion)
  #   discussion.discard!
  #   DestroyDiscussionWorker.perform_async(discussion.id)
  #   EventBus.broadcast('discussion_destroy', discussion, actor)
  # end

  def self.discard(discussion:, actor:)
    actor.ability.authorize!(:discard, discussion)
    discussion.update(discarded_at: Time.now, discarded_by: actor.id)

    discussion.polls.update_all(discarded_at: Time.now, discarded_by: actor.id)
    GenericWorker.perform_async('SearchService', 'reindex_by_discussion_id', discussion.id)

    EventBus.broadcast('discussion_discard', discussion, actor)
    discussion.created_event
  end

  def self.close(discussion:, actor:)
    actor.ability.authorize! :update, discussion
    discussion.update(closed_at: Time.now, closer_id: actor.id)
    MessageChannelService.publish_models([discussion], group_id: discussion.group_id, user_id: actor.id)
  end

  def self.reopen(discussion:, actor:)
    actor.ability.authorize! :update, discussion
    discussion.update(closed_at: nil, closer_id: nil)
    MessageChannelService.publish_models([discussion], group_id: discussion.group_id, user_id: actor.id)
  end

  def self.move(discussion:, params:, actor:)
    source = discussion.group
    destination = ModelLocator.new(:group, params).locate || NullGroup.new
    destination.present? && actor.ability.authorize!(:move_discussions_to, destination)
    actor.ability.authorize! :move, discussion
    # discussion.add_admin!(actor)

    discussion.update group: destination.presence, private: moved_discussion_privacy_for(discussion, destination)
    discussion.polls.each { |poll| poll.update(group: destination.presence) }
    ActiveStorage::Attachment.where(record: discussion.items.map(&:eventable).concat([discussion])).update_all(group_id: destination.id)

    GenericWorker.perform_async('SearchService', 'reindex_by_discussion_id', discussion.id)
    EventBus.broadcast('discussion_move', discussion, params, actor)
    Events::DiscussionMoved.publish!(discussion, actor, source)
  end

  def self.pin(discussion:, actor:)
    actor.ability.authorize! :pin, discussion

    discussion.update(pinned_at: Time.now)

    EventBus.broadcast('discussion_pin', discussion, actor)
  end

  def self.unpin(discussion:, actor:)
    actor.ability.authorize! :pin, discussion

    discussion.update(pinned_at: nil)

    EventBus.broadcast('discussion_pin', discussion, actor)
  end

  def self.update_reader(discussion:, params:, actor:)
    actor.ability.authorize! :show, discussion
    reader = DiscussionReader.for(discussion: discussion, user: actor)
    reader.update(params.slice(:volume))
    Stance.joins(:poll).
           where('polls.discussion_id': reader.discussion_id).
           where(participant_id: actor.id).
           update(params.slice(:volume))

    EventBus.broadcast('discussion_update_reader', reader, params, actor)
  end

  def self.mark_as_seen(discussion:, actor:)
    actor.ability.authorize! :mark_as_seen, discussion
    reader = DiscussionReader.for_model(discussion, actor)
    reader.viewed!
    MessageChannelService.publish_models([reader.discussion], group_id: reader.discussion.group_id)
    EventBus.broadcast('discussion_mark_as_seen', reader, actor)
  end

  def self.mark_as_read(discussion:, params:, actor:)
    actor.ability.authorize! :mark_as_read, discussion
    RetryOnError.with_limit(2) do
      sequence_ids = RangeSet.ranges_to_list(RangeSet.to_ranges(params[:ranges]))
      NotificationService.viewed_events(actor_id: actor.id, discussion_id: discussion.id, sequence_ids: sequence_ids)
      reader = DiscussionReader.for_model(discussion, actor)
      reader.viewed!(params[:ranges])
      EventBus.broadcast('discussion_mark_as_read', reader, actor)
    end
  end

  def self.dismiss(discussion:, params:, actor:)
    actor.ability.authorize! :dismiss, discussion
    reader = DiscussionReader.for(user: actor, discussion: discussion)
    reader.dismiss!
    EventBus.broadcast('discussion_dismiss', reader, actor)
  end

  def self.recall(discussion:, params:, actor:)
    actor.ability.authorize! :dismiss, discussion
    reader = DiscussionReader.for(user: actor, discussion: discussion)
    reader.recall!
    EventBus.broadcast('discussion_recall', reader, actor)
  end

  def self.moved_discussion_privacy_for(discussion, destination)
    case destination.discussion_privacy_options
    when 'public_only'  then false
    when 'private_only' then true
    else                     discussion.private
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
        DiscussionReader.for(user: user, discussion: discussion).viewed!(sequence_ids)
      end
    end
  end

  def self.add_users(discussion:, actor:, user_ids:, emails:, audience:)
    users = UserInviter.where_or_create!(actor: actor,
                                         user_ids: user_ids,
                                         emails: emails,
                                         model: discussion,
                                         audience: audience)


    volumes = {}
    Membership.where(group_id: discussion.group_id,
                     user_id: users.pluck(:id)).find_each do |m|
      volumes[m.user_id] = m.volume
    end
    
    DiscussionReader.
      where(discussion_id: discussion.id, user_id: users.map(&:id)).
      where("revoked_at is not null").update_all(revoked_at: nil, revoker_id: nil)

    new_discussion_readers = users.map do |user|
      DiscussionReader.new(user: user,
                           discussion: discussion,
                           inviter: if volumes[user.id] then nil else actor end,
                           admin: !discussion.group_id,
                           volume: volumes[user.id] || DiscussionReader.volumes[:normal])
    end

    DiscussionReader.import(new_discussion_readers, on_duplicate_key_ignore: true)

    discussion.update_members_count
    users
  end

end
