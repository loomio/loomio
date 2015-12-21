class DiscussionService
  def self.recount_everything!
    # I'm not sure anyone will need this .. but it's cool sql
    # WHOA I TOTALLY NEEDED IT!
    ActiveRecord::Base.connection.execute(
      "UPDATE discussion_readers SET
       read_comments_count = (SELECT count(id) FROM events WHERE discussion_id = discussion_readers.discussion_id AND events.created_at <= discussion_readers.last_read_at AND events.kind = 'new_comment'),
       read_items_count = (SELECT count(id) FROM events WHERE discussion_id = discussion_readers.discussion_id AND events.created_at <= discussion_readers.last_read_at AND events.kind IN ('#{Discussion::THREAD_ITEM_KINDS.join('\', \'')}') ),
       read_salient_items_count = (SELECT count(id) FROM events WHERE discussion_id = discussion_readers.discussion_id AND events.created_at <= discussion_readers.last_read_at AND events.kind IN ('#{Discussion::SALIENT_ITEM_KINDS.join('\', \'')}') )")
    ActiveRecord::Base.connection.execute(
      "UPDATE discussions SET
       comments_count = (SELECT count(id) FROM events WHERE discussions.id = events.discussion_id AND events.kind = 'new_comment'),
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
    discussion.author = actor
    discussion.inherit_group_privacy!
    return false unless discussion.valid?

    actor.ability.authorize! :create, discussion
    discussion.save!
    Draft.purge(user: actor, draftable: discussion.group, field: :discussion)
    SearchVector.index! discussion.id
    Events::NewDiscussion.publish!(discussion)
  end

  def self.destroy(discussion:, actor:)
    actor.ability.authorize!(:destroy, discussion)
    discussion.delayed_destroy
  end

  def self.update(discussion:, params:, actor:)
    actor.ability.authorize! :update, discussion

    [:private, :title, :description, :uses_markdown].each do |attr|
      discussion.send("#{attr}=", params[attr]) if params.has_key?(attr)
    end

    if actor.ability.can? :update, discussion.group
      discussion.iframe_src = params[:iframe_src]
    end

    return false unless discussion.valid?
    return discussion if discussion.changed == ['uses_markdown']
    return discussion unless discussion.changed?

    discussion.save!
    event = Events::DiscussionEdited.publish!(discussion, actor)

    SearchVector.index! discussion.id
    DiscussionReader.for(discussion: discussion, user: actor).set_volume_as_required!
    event
  end

  def self.move(discussion:, params:, actor:)
    destination = Group.find_by id: params[:group_id]
    actor.ability.authorize! :move_discussions_to, destination
    actor.ability.authorize! :move, discussion

    discussion.update group: destination, private: moved_discussion_privacy_for(discussion, destination)
    discussion
  end

  def self.update_reader(discussion:, params:, actor:)
    reader = DiscussionReader.for(discussion: discussion, user: actor)
    actor.ability.authorize! :show, discussion

    [:starred, :volume].each do |attr|
      reader.send("#{attr}=", params[attr]) if params.has_key?(attr)
    end

    reader.save!
  end

  def self.mark_as_read(discussion:, params:, actor:)
    actor.ability.authorize! :show, discussion

    target_to_read = Event.where(discussion_id: discussion.id, sequence_id: params[:sequence_id]).first || discussion
    DiscussionReader.for(user: actor, discussion: discussion).viewed! target_to_read.created_at
  end

  def self.moved_discussion_privacy_for(discussion, destination)
    case destination.discussion_privacy_options
    when 'public_only'  then false
    when 'private_only' then true
    else                     discussion.private
    end
  end

end
