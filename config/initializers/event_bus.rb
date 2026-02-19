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
    if event.topic
      reader = TopicReader.for_model(event.topic.topicable, event.user.presence || event.eventable.real_participant)
                               .update_reader(ranges: event.sequence_id,
                                              volume: :loud)
    end
  end

  # if the user marks a discussion as read, update their other open tabs
  config.listen('discussion_mark_as_read',
                'discussion_dismiss',
                'discussion_mark_as_seen') do |reader|
    topicable = reader.topic&.topicable
    if topicable.is_a?(Discussion)
      MessageChannelService.publish_models([topicable],
                                           serializer: DiscussionSerializer,
                                           root: :discussions,
                                           user_id: reader.user_id)
    end
  end
end
