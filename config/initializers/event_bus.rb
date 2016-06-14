EventBus.configure do |config|

  # Purge drafts after model creation
  config.listen('discussion_create') { |discussion| Draft.purge(user: discussion.author, draftable: discussion.group, field: :discussion) }
  config.listen('comment_create')    { |comment|    Draft.purge_without_delay(user: comment.user, draftable: comment.discussion, field: :comment) }
  config.listen('motion_create')     { |motion|     Draft.purge(user: motion.author, draftable: motion.discussion, field: :motion) }
  config.listen('vote_create')       { |vote|       Draft.purge(user: vote.user, draftable: vote.motion, field: :vote) }

  # Index search vectors after model creation
  config.listen('discussion_create', 'discussion_update') { |discussion| SearchVector.index! discussion.id }
  config.listen('motion_create', 'motion_update')         { |motion|     SearchVector.index! motion.discussion_id }
  config.listen('comment_create', 'comment_update')       { |comment|    SearchVector.index! comment.discussion_id }

  # send bulk emails after events
  Event::BULK_MAIL_KINDS.each do |kind|
    config.listen("#{kind}_event") do |event|
      BaseMailer.send_bulk_mail(to: Queries::UsersToEmailQuery.send(kind, event.eventable)) do |user|
        ThreadMailer.delay(priority: 2).send(kind, user, event)
      end
    end
  end

  # send individual emails after thread events
  # Single mail kinds is only Comment replied to and User mentioned.
  Event::SINGLE_MAIL_KINDS.each do |kind|
    config.listen("#{kind}_event") do |event, user|
      ThreadMailer.delay(priority: 2).send(kind, user, event) if user.email_when_mentioned
    end
  end


  # send individual emails after user events
  config.listen('membership_request_approved_event') { |event, user| UserMailer.delay(priority: 2).group_membership_approved(user, event.group) }

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
    DiscussionReader.for_model(event.eventable).author_thread_item!(event.created_at)
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
  config.listen('discussion_create') do |discussion, actor|
    DiscussionReader.for(discussion: discussion, user: actor).set_volume! :loud
  end

  config.listen('discussion_update', 'comment_like') do |model, actor|
    DiscussionReader.for_model(model, actor).set_volume_as_required!
  end

  config.listen('discussion_reader_viewed!') do |discussion, actor|

    reader_cache = DiscussionReaderCache.new(user: actor, discussions: Array(discussion))
    collection = ActiveModel::ArraySerializer.new([discussion], each_serializer: MarkedAsRead::DiscussionSerializer, root: 'discussions', scope: { reader_cache: reader_cache } )

    MessageChannelService.publish(collection, to: actor)
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
                'new_coordinator_event') { |event, user| event.notify!(user) }

  # notify users of motion closing soon
  config.listen('motion_closing_soon_event') do |event|
    Queries::UsersByVolumeQuery.normal_or_loud(event.discussion).find_each { |user| event.notify!(user) }
  end

  # notify users of motion outcome created
  config.listen('motion_outcome_created_event') do |event|
    Queries::UsersByVolumeQuery.normal_or_loud(event.discussion).without(event.motion.outcome_author).find_each { |user| event.notify!(user) }
  end

  # perform group creation
  config.listen('group_create') do |group, actor|
    group.add_default_content! if group.is_parent?
  end

  # collect user deactivation response
  config.listen('user_deactivate') { |user, actor, params| UserDeactivationResponse.create(user: user, body: params[:deactivation_response]) }

end
