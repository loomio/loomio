class DiscussionService
  def self.recount_everything!
    # I'm not sure anyone will need this .. but it's cool sql
    ActiveRecord::Base.connection.execute(
      "UPDATE discussion_readers SET
       read_comments_count = (SELECT count(id) FROM comments WHERE discussion_id = discussion_readers.discussion_id AND comments.created_at <= discussion_readers.last_read_at ),
       read_items_count = (SELECT count(id) FROM events WHERE discussion_id = discussion_readers.discussion_id AND events.created_at <= discussion_readers.last_read_at ),
       read_salient_items_count = (SELECT count(id) FROM events WHERE discussion_id = discussion_readers.discussion_id AND events.created_at <= discussion_readers.last_read_at AND events.kind IN ('#{Discussion::SALIENT_ITEM_KINDS.join('\', \'')}') )", )
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
    ThreadSearchService.index! discussion.id
    Events::NewDiscussion.publish!(discussion)
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
    
    event = Events::DiscussionEdited.publish!(discussion, actor)
    discussion.save!

    ThreadSearchService.index! discussion.id
    DiscussionReader.for(discussion: discussion, user: actor).set_volume_as_required!
    event
  end
end
