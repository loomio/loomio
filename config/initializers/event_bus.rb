require 'event_bus'

EventBus.configure do |config|
  config.listen('new_comment_event',
                'new_discussion_event',
                'discussion_edited_event',
                'poll_created_event',
                'poll_edited_event',
                'stance_created_event',
                'outcome_created_event',
                'poll_closed_by_user_event') do |event|
    if event.discussion
      reader = DiscussionReader.for_model(event.discussion, event.real_user)
                               .update_reader(ranges: event.sequence_id,
                                              volume: :loud)
      # MessageChannelService.publish_models([reader], root: :discussions, user_id: event.real_user.id)
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
                'poll_update') { |model| SearchIndexWorker.perform_async(Array(model.discussion_id)) }


  # if the user marks a discussion as read, update their other open tabs
  config.listen('discussion_mark_as_read',
                'discussion_dismiss',
                'discussion_mark_as_seen') do |reader|
    MessageChannelService.publish_models(reader, serializer: DiscussionReaderSerializer, root: :discussions, user_id: reader.user_id)
  end

  # update discussion or comment versions_count when title or description edited
  config.listen('discussion_update', 'comment_update', 'poll_update', 'stance_update') { |model| model.update_versions_count }


  # publish reply event after comment creation
  config.listen('comment_create') { |comment| Events::CommentRepliedTo.publish!(comment) if comment.parent }

  # update discussion importance
  config.listen('discussion_pin',
                'poll_create',
                'poll_close',
                'poll_destroy',
                'poll_expire') { |model| model.discussion&.update_importance }
end
