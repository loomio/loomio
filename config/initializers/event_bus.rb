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
    # real_participant only exists on Comment and Stance (for anonymous-voting
    # flows where event.user is the placeholder and the eventable holds the
    # real actor). Other eventables (Poll, Discussion, Outcome) don't have it,
    # so skip the fallback there.
    reader_user = event.user.presence
    reader_user ||= event.eventable.real_participant if event.eventable.respond_to?(:real_participant)

    if event.discussion && reader_user
      DiscussionReader.for_model(event.discussion, reader_user)
                      .update_reader(ranges: event.sequence_id, volume: :loud)
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
