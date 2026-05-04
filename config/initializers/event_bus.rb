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
    reader_user = event.user.presence
    reader_user ||= event.eventable.real_participant if event.eventable.respond_to?(:real_participant)

    if event.topic && reader_user
      TopicReader.for(topic: event.topic, user: reader_user)
                 .update_reader(ranges: event.sequence_id, volume: :loud)
    end
  end
end
