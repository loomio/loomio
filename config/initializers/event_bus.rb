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
      MessageChannelService.publish_data(ActiveModel::ArraySerializer.new([reader],
                                         each_serializer: DiscussionReaderSerializer,
                                         root: :discussions).as_json,
                                         to: event.real_user.message_channel)
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

  # send memos to client side after comment change
  config.listen('reaction_destroy') { |reaction| Memos::ReactionDestroyed.publish!(reaction: reaction) }

  config.listen('event_remove_from_thread') do |event|
    MessageChannelService.publish_model(event, serializer: Events::BaseSerializer)
  end

  config.listen('discussion_mark_as_read',
                'discussion_dismiss',
                'discussion_mark_as_seen') do |reader|
    MessageChannelService.publish_data(ActiveModel::ArraySerializer.new([reader], each_serializer: DiscussionReaderSerializer, root: :discussions).as_json, to: reader.message_channel)
  end

  # config.listen('discussion_mark_as_seen') do |reader|
  #   MessageChannelService.publish_model(reader.discussion)
  # end

  # alert clients that notifications have been read
  config.listen('notification_viewed') do |actor|
    MessageChannelService.publish_data(NotificationCollection.new(actor).serialize!, to: actor.message_channel)
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

  # move events to new discussion on fork
  config.listen('discussion_fork') { |source, target| DiscussionForker.new(source, target).fork! }
end
