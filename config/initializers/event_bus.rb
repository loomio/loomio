require 'event_bus'

EventBus.configure do |config|

  # Purge drafts after model creation
  config.listen('discussion_create') { |discussion| Draft.purge(user: discussion.author, draftable: discussion.group, field: :discussion) }
  config.listen('comment_create')    { |comment|    Draft.purge_without_delay(user: comment.user, draftable: comment.discussion, field: :comment) }
  config.listen('motion_create')     { |motion|     Draft.purge(user: motion.author, draftable: motion.discussion, field: :motion) }
  config.listen('vote_create')       { |vote|       Draft.purge(user: vote.user, draftable: vote.motion, field: :vote) }
  config.listen('poll_create')       { |poll|       Draft.purge(user: poll.author, draftable: poll.discussion, field: :poll) }

  # Add creator to group on group creation
  config.listen('group_create') do |group, actor|
    if actor.is_logged_in?
      group.add_admin! actor
    elsif actor.email.present?
      InvitationService.invite_creator_to_group(group: group, creator: actor)
    end
  end

  # Index search vectors after model creation
  config.listen('discussion_create',
                'discussion_update',
                'motion_create',
                'motion_update',
                'comment_create',
                'comment_update',
                'poll_create',
                'poll_update') { |model| SearchVector.index! model.discussion_id }

  # sync poll's discussion with it's group
  config.listen('poll_create', 'poll_update') do |poll|
    poll.update(group_id: poll.discussion.group_id) if poll.discussion
  end

  # add creator to group if one doesn't exist
  config.listen('membership_join_group') { |group, actor| group.update(creator: actor) unless group.creator_id.present? }

  # send memos to client side after comment change
  config.listen('comment_destroy') { |comment|      Memos::CommentDestroyed.publish!(comment) }
  config.listen('comment_update')  { |comment|      Memos::CommentUpdated.publish!(comment) }
  config.listen('comment_unlike')  { |comment_vote| Memos::CommentUnliked.publish!(comment: comment_vote.comment, user: comment_vote.user) }

  config.listen('new_discussion_event') { |event| DiscussionReader.for_model(event.eventable).participate! }

  # update discussion reader after discussion creation / edition
  config.listen('discussion_create',
                'discussion_update',
                'comment_like') do |model, actor|
    DiscussionReader.for_model(model, actor).update_reader(volume: :loud)
  end

  config.listen('discussion_reader_viewed!',
                'discussion_reader_dismissed!') do |discussion, actor|

    reader_cache = Caches::DiscussionReader.new(user: actor, parents: Array(discussion))
    collection = ActiveModel::ArraySerializer.new([discussion], each_serializer: MarkedAsRead::DiscussionSerializer, root: 'discussions', scope: { reader_cache: reader_cache } )

    MessageChannelService.publish(collection, to: actor)
  end

  # alert clients that notifications have been read
  config.listen('notification_viewed') do |actor|
    MessageChannelService.publish(NotificationCollection.new(actor).serialize!, to: actor)
  end

  # update discussion or comment versions_count when title or description edited
  config.listen('discussion_update', 'comment_update') { |model| model.update_versions_count }

  # update stance data for polls
  config.listen('stance_create')  { |stance| stance.poll.update_stance_data }

  # publish reply event after comment creation
  config.listen('comment_create') { |comment| Events::CommentRepliedTo.publish!(comment) }

  # publish mention events after model create / update
  config.listen('comment_create',
                'comment_update',
                'motion_create',
                'motion_update',
                'discussion_create',
                'discussion_update') do |model, actor|
    Queries::UsersToMentionQuery.for(model).each { |user| Events::UserMentioned.publish!(model, actor, user) }
  end

  # email and notify users of events
  Event::KINDS.each do |kind|
    config.listen("#{kind}_event") { |event| event.trigger! }
  end

  # nullify parent_id on children of destroyed comment
  config.listen('comment_destroy') { |comment| Comment.where(parent_id: comment.id).update_all(parent_id: nil) }

  # collect user deactivation response
  config.listen('user_deactivate') { |user, actor, params| UserDeactivationResponse.create(user: user, body: params[:deactivation_response]) }
end
