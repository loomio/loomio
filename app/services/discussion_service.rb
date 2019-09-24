class DiscussionService
  def self.create(discussion:, actor:)
    actor.ability.authorize! :create, discussion
    discussion.author = actor
    discussion.inherit_group_privacy!
    return false unless discussion.valid?

    discussion.save!
    EventBus.broadcast('discussion_create', discussion, actor)
    Events::NewDiscussion.publish!(discussion)
  end

  def self.destroy(discussion:, actor:)
    actor.ability.authorize!(:destroy, discussion)
    discussion.destroy!
    EventBus.broadcast('discussion_destroy', discussion, actor)
  end

  def self.update(discussion:, params:, actor:)
    actor.ability.authorize! :update, discussion

    HasRichText.assign_attributes_and_update_files(discussion, params.except(:document_ids))
    version_service = DiscussionVersionService.new(discussion: discussion, new_version: discussion.changes.empty?)
    discussion.assign_attributes(params.slice(:document_ids))
    discussion.document_ids = [] if params.slice(:document_ids).empty?
    is_new_version = discussion.is_new_version?
    return false unless discussion.valid?
    rearrange = discussion.max_depth_changed?
    discussion.save!
    # EventService.delay.rearrange_events(discussion) if rearrange

    version_service.handle_version_update!
    EventBus.broadcast('discussion_update', discussion, actor, params)
    Events::DiscussionEdited.publish!(discussion, actor) if is_new_version
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
    destination = ModelLocator.new(:group, params).locate
    actor.ability.authorize! :move_discussions_to, destination
    actor.ability.authorize! :move, discussion

    discussion.update group: destination, private: moved_discussion_privacy_for(discussion, destination)
    discussion.polls.each { |poll| poll.update(group: destination) }

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

  def self.mark_summary_email_as_read (user, params)
    time_start  = Time.at(params[:time_start].to_i).utc
    time_finish = Time.at(params[:time_finish].to_i).utc
    time_range = time_start..time_finish

    Queries::VisibleDiscussions.new(user: user).
                                    unread.
                                    last_activity_after(time_start).each do |discussion|
      sequence_ids = discussion.items.where("events.created_at": time_range).pluck(:sequence_id)
      DiscussionReader.for(user: user, discussion: discussion).viewed!(sequence_ids)
    end
  end

end
