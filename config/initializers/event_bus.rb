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
      reader = DiscussionReader.for_model(event.discussion, event.user.presence || event.eventable.real_participant)
                               .update_reader(ranges: event.sequence_id,
                                              volume: :loud)
      # MessageChannelService.publish_models([reader], root: :discussions, user_id: event.real_user.id)
    end
  end

  # if the user marks a discussion as read, update their other open tabs
  config.listen('discussion_mark_as_read',
                'discussion_dismiss',
                'discussion_mark_as_seen') do |reader|
    collection = Discussion.where(id: reader.discussion_id)
    MessageChannelService.publish_models([reader.discussion],
                                         serializer: DiscussionSerializer,
                                         root: :discussions,
                                         user_id: reader.user_id)
  end
end
