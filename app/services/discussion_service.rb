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
    discussion.destroy
    EventBus.broadcast('discussion_destroy', discussion, actor)
  end

  def self.update(discussion:, params:, actor:)
    actor.ability.authorize! :update, discussion

    discussion.assign_attributes(params.slice(:private, :title, :description, :pinned))
    version_service = DiscussionVersionService.new(discussion: discussion, new_version: discussion.changes.empty?)
    discussion.attachment_ids = params[:attachment_ids]

    return false unless discussion.valid?
    discussion.save!

    version_service.handle_version_update!
    EventBus.broadcast('discussion_update', discussion, actor, params)
    Events::DiscussionEdited.publish!(discussion, actor)
  end

  def self.move(discussion:, params:, actor:)
    source = discussion.group
    destination = ModelLocator.new(:group, params).locate
    actor.ability.authorize! :move_discussions_to, destination
    actor.ability.authorize! :move, discussion

    discussion.update group: destination, private: moved_discussion_privacy_for(discussion, destination)

    EventBus.broadcast('discussion_move', discussion, params, actor)
    Events::DiscussionMoved.publish!(discussion, actor, source)
  end

  def self.pin(discussion:, actor:)
    actor.ability.authorize! :pin, discussion

    discussion.update(pinned: !discussion.pinned)

    EventBus.broadcast('discussion_pin', discussion, actor)
  end

  def self.update_reader(discussion:, params:, actor:)
    actor.ability.authorize! :show, discussion
    reader = DiscussionReader.for(discussion: discussion, user: actor)
    reader.update(params.slice(:volume))

    EventBus.broadcast('discussion_update_reader', reader, params, actor)
  end

  def self.mark_as_seen(discussion:, actor:)
    actor.ability.authorize! :mark_as_seen, discussion
    DiscussionReader.for_model(discussion, actor).update_attribute(:last_read_at, discussion.created_at)
    EventBus.broadcast('discussion_mark_as_seen', discussion.reload, actor)

  end

  def self.mark_as_read(discussion:, params:, actor:)
    actor.ability.authorize! :mark_as_read, discussion
    reader = DiscussionReader.for_model(discussion, actor).viewed!(params[:ranges])
    EventBus.broadcast('discussion_mark_as_read', reader, actor)
  end

  def self.dismiss(discussion:, params:, actor:)
    actor.ability.authorize! :dismiss, discussion
    reader = DiscussionReader.for(user: actor, discussion: discussion).dismiss!
    EventBus.broadcast('discussion_dismiss', reader, actor)
  end

  def self.moved_discussion_privacy_for(discussion, destination)
    case destination.discussion_privacy_options
    when 'public_only'  then false
    when 'private_only' then true
    else                     discussion.private
    end
  end

end
