class DiscussionService
  def self.recount_everything!
    # I'm not sure anyone will need this .. but it's cool sql
    # WHOA I TOTALLY NEEDED IT!
    ActiveRecord::Base.connection.execute(
      "UPDATE discussion_readers SET
       read_items_count = (SELECT count(id) FROM events WHERE discussion_id = discussion_readers.discussion_id AND events.created_at <= discussion_readers.last_read_at AND events.kind IN ('#{Discussion::THREAD_ITEM_KINDS.join('\', \'')}') ),
       read_salient_items_count = (SELECT count(id) FROM events WHERE discussion_id = discussion_readers.discussion_id AND events.created_at <= discussion_readers.last_read_at AND events.kind IN ('#{Discussion::SALIENT_ITEM_KINDS.join('\', \'')}') )")
    ActiveRecord::Base.connection.execute(
      "UPDATE discussions SET
       items_count = (SELECT count(id) FROM events WHERE discussions.id = events.discussion_id AND events.kind IN ('#{Discussion::THREAD_ITEM_KINDS.join('\', \'')}') ),
       salient_items_count = (SELECT count(id) FROM events WHERE discussions.id = events.discussion_id AND events.kind IN ('#{Discussion::SALIENT_ITEM_KINDS.join('\', \'')}') )")
  end

  def self.mark_as_participating!
    Discussion.reset_column_information
    Discussion.includes(:events).find_each(batch_size: 100) do |discussion|
      participant_ids = (discussion.events.pluck(:user_id) << discussion.author_id).compact.uniq
      DiscussionReader.where(user_id: participant_ids, discussion: discussion).update_all(participating: true)
      yield if block_given?
    end
  end

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

    discussion.assign_attributes(params.slice(:private, :title, :description))
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

  def self.update_reader(discussion:, params:, actor:)
    actor.ability.authorize! :show, discussion
    DiscussionReader.for(discussion: discussion, user: actor).update(params.slice(:starred, :volume))

    EventBus.broadcast('discussion_update_reader', discussion, params, actor)
  end

  def self.mark_as_read(discussion:, params:, actor:)
    actor.ability.authorize! :mark_as_read, discussion

    target_to_read = Event.where(discussion_id: discussion.id, sequence_id: params[:sequence_id]).first || discussion
    DiscussionReader.for(user: actor, discussion: discussion).viewed! target_to_read.created_at
  end

  def self.dismiss(discussion:, params:, actor:)
    actor.ability.authorize! :dismiss, discussion
    DiscussionReader.for(user: actor, discussion: discussion).dismiss!
  end

  def self.moved_discussion_privacy_for(discussion, destination)
    case destination.discussion_privacy_options
    when 'public_only'  then false
    when 'private_only' then true
    else                     discussion.private
    end
  end

end
