EventBus.configure do |config|

  # Purge drafts after model creation
  config.listen('discussion_create') { |discussion| Draft.purge(user: discussion.author, draftable: discussion.group, field: :discussion) }
  config.listen('comment_create')    { |comment|    Draft.purge_without_delay(user: comment.user, draftable: comment.discussion, field: :comment) }
  config.listen('motion_create')     { |motion|     Draft.purge(user: motion.author, draftable: motion.discussion, field: :motion) }
  config.listen('vote_create')       { |vote|       Draft.purge(user: vote.user, draftable: vote.motion, field: :vote) }

  # Add creator to group on group creation
  config.listen('group_create') do |group, actor|
    if actor.is_logged_in?
      group.add_admin! actor
    elsif actor.email.present?
      InvitationService.invite_creator_to_group(group: group, creator: actor)
    end
  end

  # Index search vectors after model creation
  config.listen('discussion_create', 'discussion_update') { |discussion| SearchVector.index! discussion.id }
  config.listen('motion_create', 'motion_update')         { |motion|     SearchVector.index! motion.discussion_id }
  config.listen('comment_create', 'comment_update')       { |comment|    SearchVector.index! comment.discussion_id }

  # send bulk emails after events
  Event::BULK_MAIL_KINDS.each do |kind|
    delay = ENV.fetch("LOOMIO_BULK_MAIL_DELAY", 0).to_i.seconds
    config.listen("#{kind}_event") { |event| SendBulkEmailJob.set(wait: delay).perform_later(event.id) }
  end

  # send individual emails after thread events
  # Single mail kinds is only Comment replied to and User mentioned.
  Event::SINGLE_MAIL_KINDS.each do |kind|
    config.listen("#{kind}_event") do |event, user|
      ThreadMailer.delay(priority: 2).send(kind, user, event) if user.email_when_mentioned
    end
  end


  # send individual emails after user events
  config.listen('membership_request_approved_event') { |event, user| UserMailer.delay(priority: 2).group_membership_approved(user, event.eventable.group) }
  config.listen('membership_requested_event')        { |event| GroupMailer.new_membership_request(event.eventable) }

  # notify user of acceptance to group
  config.listen('user_added_to_group_event') do |event, user, message|
    UserMailer.delay(priority: 1).added_to_group(
      user:    event.eventable.user,
      group:   event.eventable.group,
      inviter: event.user,
      message: message
    )
  end

  # add creator to group if one doesn't exist
  config.listen('membership_join_group') { |group, actor| group.update(creator: actor) unless group.creator_id.present? }

  # send memos to client side after comment change
  config.listen('comment_destroy') { |comment|      Memos::CommentDestroyed.publish!(comment) }
  config.listen('comment_update')  { |comment|      Memos::CommentUpdated.publish!(comment) }
  config.listen('comment_unlike')  { |comment_vote| Memos::CommentUnliked.publish!(comment: comment_vote.comment, user: comment_vote.user) }

  # update discussion reader after thread item creation
  config.listen('new_comment_event',
                'new_motion_event',
                'new_vote_event',
                'motion_closed_event',
                'motion_closed_by_user_event',
                'motion_outcome_created_event',
                'motion_outcome_updated_event') do |event|
    DiscussionReader.for_model(event.eventable).update_reader(read_at: event.created_at, participate: true, volume: :loud)
  end

  config.listen('new_discussion_event') { |event| DiscussionReader.for_model(event.eventable).participate! }

  config.listen('new_discussion_event',
                'new_motion_event',
                'new_comment_event',
                'new_vote_event',
                'comment_replied_to_event',
                'discussion_title_edited_event',
                'motion_close_date_edited_event',
                'motion_closed_event',
                'motion_closed_by_user_event',
                'motion_name_edited_event',
                'discussion_description_edited_event',
                'motion_description_edited_event',
                'comment_liked_event') do |event|
    MessageChannelService.publish(EventCollection.new(event).serialize!, to: event.eventable.group)
  end

  config.listen('discussion_moved_event') do |event|
    MessageChannelService.publish(EventCollection.new(event).serialize!, to: event.eventable)
  end

  # update discussion reader after discussion creation / edition
  config.listen('discussion_create',
                'discussion_update',
                'comment_like') do |model, actor|
    DiscussionReader.for_model(model, actor).update_reader(volume: :loud)
  end

  config.listen('discussion_reader_viewed!',
                'discussion_reader_dismissed!') do |discussion, actor|

    reader_cache = DiscussionReaderCache.new(user: actor, discussions: Array(discussion))
    collection = ActiveModel::ArraySerializer.new([discussion], each_serializer: MarkedAsRead::DiscussionSerializer, root: 'discussions', scope: { reader_cache: reader_cache } )

    MessageChannelService.publish(collection, to: actor)
  end

  # alert clients that notifications have been read
  config.listen('notification_viewed') do |actor|
    MessageChannelService.publish(NotificationCollection.new(actor).serialize!, to: actor)
  end

  # update discussion or comment versions_count when title or description edited
  config.listen('discussion_update', 'comment_update') do |model|
    model.update_versions_count
  end

  # publish reply and mention events after comment creation
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

  # notify users of events
  config.listen('membership_request_approved_event',
                'comment_replied_to_event',
                'user_mentioned_event',
                'motion_closed_event',
                'invitation_accepted_event',
                'new_coordinator_event',
                'user_added_to_group_event') { |event, user| event.notify!(user) }

  # bulk notify users of events
  config.listen('motion_outcome_created_event',
                'motion_closing_soon_event',
                'membership_requested_event',
                'comment_liked_event') do |event|
    event.notifications.import event.users_to_notify.map { |user| event.notify!(user, persist: false) }
  end

  # collect user deactivation response
  config.listen('user_deactivate') { |user, actor, params| UserDeactivationResponse.create(user: user, body: params[:deactivation_response]) }

  config.listen('comment_destroy') { |comment| Comment.where(parent_id: comment.id).update_all(parent_id: nil) }
end
