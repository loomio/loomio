class DiscussionService

  class EventNotSavedError
    def initialize(data)
      @data = data
    end
  end

  def self.create(discussion:, actor:, params: {})
    actor.ability.authorize! :create, discussion
    actor.ability.authorize! :announce, discussion if params[:recipient_audience]

    discussion.author = actor

    #these should really be sent from the client, but it's ok here for now
    discussion.max_depth = discussion.group.new_threads_max_depth
    discussion.newest_first = discussion.group.new_threads_newest_first

    return false unless discussion.valid?

    discussion.save!

    DiscussionReader.for(user: actor, discussion: discussion)
                    .update(admin: true, inviter_id: actor.id)

    users = add_users(discussion: discussion,
                      actor: actor,
                      user_ids: params[:recipient_user_ids],
                      emails: params[:recipient_emails],
                      audience: params[:recipient_audience])

    EventBus.broadcast('discussion_create', discussion, actor)
    Events::NewDiscussion.publish!(discussion: discussion,
                                   recipient_user_ids: users.pluck(:id),
                                   recipient_audience: params[:recipient_audience])

  end

  def self.update(discussion:, actor:, params:)
    actor.ability.authorize! :update, discussion
    HasRichText.assign_attributes_and_update_files(discussion, params)

    return false unless discussion.valid?
    rearrange = discussion.max_depth_changed?
    discussion.save!
    EventService.delay.repair_thread(discussion.id) if rearrange

    users = add_users(discussion: discussion,
                      actor: actor,
                      user_ids: params[:recipient_user_ids],
                      emails: params[:recipient_emails],
                      audience: params[:recipient_audience])

    EventBus.broadcast('discussion_update', discussion, actor, params)

    Events::DiscussionEdited.publish!(discussion: discussion,
                                      recipient_user_ids: users.pluck(:id),
                                      recipient_audience: params[:recipient_audience],
                                      recipient_message: params[:recipient_message])
  end

  def self.announce(discussion:, actor:, params:)
    actor.ability.authorize! :announce, discussion

    users = add_users(discussion: discussion,
                      actor: actor,
                      user_ids: params[:recipient_user_ids],
                      emails: params[:recipient_emails],
                      audience: params[:recipient_audience])

    Events::DiscussionAnnounced.publish!(discussion: discussion,
                                         actor: actor,
                                         recipient_user_ids: users.pluck(:id),
                                         recipient_audience: params[:recipient_audience])
  end

  def self.destroy(discussion:, actor:)
    actor.ability.authorize!(:destroy, discussion)
    discussion.discard!
    DestroyDiscussionWorker.perform_async(discussion.id)
    EventBus.broadcast('discussion_destroy', discussion, actor)
  end

  def self.discard(discussion:, actor:)
    actor.ability.authorize!(:discard, discussion)
    discussion.discard!
    EventBus.broadcast('discussion_discard', discussion, actor)
    discussion.created_event
  end

  def self.close(discussion:, actor:)
    actor.ability.authorize! :update, discussion
    discussion.update(closed_at: Time.now)

    EventBus.broadcast('discussion_close', discussion, actor)
    Events::DiscussionClosed.publish!(discussion, actor)
  end

  def self.reopen(discussion:, actor:)
    actor.ability.authorize! :update, discussion
    discussion.update(closed_at: nil)

    EventBus.broadcast('discussion_reopen', discussion, actor)
    Events::DiscussionReopened.publish!(discussion, actor)
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

    EventBus.broadcast('discussion_move', discussion, params, actor)
    Events::DiscussionMoved.publish!(discussion, actor, source)
  end

  def self.pin(discussion:, actor:)
    actor.ability.authorize! :pin, discussion

    discussion.update(pinned: !discussion.pinned)

    EventBus.broadcast('discussion_pin', discussion, actor)
  end

  def self.fork(discussion:, actor:)
    actor.ability.authorize! :fork, discussion
    source = discussion.forked_items.first.discussion

    return false unless event = create(discussion: discussion, actor: actor)

    EventBus.broadcast('discussion_fork', source, event.eventable, actor)
    Events::DiscussionForked.publish!(event.eventable, source)
  end

  def self.update_reader(discussion:, params:, actor:)
    actor.ability.authorize! :show, discussion
    reader = DiscussionReader.for(discussion: discussion, user: actor)
    reader.update(params.slice(:volume))

    EventBus.broadcast('discussion_update_reader', reader, params, actor)
  end

  def self.mark_as_seen(discussion:, actor:)
    actor.ability.authorize! :mark_as_seen, discussion
    reader = DiscussionReader.for_model(discussion, actor)
    reader.viewed!
    MessageChannelService.publish_models(reader.discussion, group_id: reader.discussion.group_id)
    EventBus.broadcast('discussion_mark_as_seen', reader, actor)
  end

  def self.mark_as_read(discussion:, params:, actor:)
    actor.ability.authorize! :mark_as_read, discussion
    reader = DiscussionReader.for_model(discussion, actor)
    reader.viewed!(params[:ranges])
    EventBus.broadcast('discussion_mark_as_read', reader, actor)
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

  def self.mark_summary_email_as_read(user_id, params)
    user = User.find_by!(id: user_id)
    time_start  = Time.at(params[:time_start].to_i).utc
    time_finish = Time.at(params[:time_finish].to_i).utc
    time_range = time_start..time_finish

    DiscussionQuery.visible_to(user: user, only_unread: true, or_public: false, or_subgroups: false).last_activity_after(time_start).each do |discussion|
      sequence_ids = discussion.items.where("events.created_at": time_range).pluck(:sequence_id)
      DiscussionReader.for(user: user, discussion: discussion).viewed!(sequence_ids)
    end
  end

  def self.add_users(discussion:, actor:, user_ids:, emails:, audience:)
    users = UserInviter.where_or_create!(inviter: actor,
                                         user_ids: user_ids,
                                         emails: emails,
                                         model: discussion,
                                         audience: audience)


    volumes = {}
    Membership.where(group_id: discussion.group_id,
                     user_id: users.pluck(:id)).find_each do |m|
      volumes[m.user_id] = m.volume
    end

    new_discussion_readers = users.map do |user|
      DiscussionReader.new(user: user,
                           discussion: discussion,
                           inviter: actor,
                           volume: volumes[user.id] || DiscussionReader.volumes[:normal])
    end

    DiscussionReader.import(new_discussion_readers, on_duplicate_key_ignore: true)

    discussion.update_members_count
    users
  end

end
