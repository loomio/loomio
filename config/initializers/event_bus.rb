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
      reader = TopicReader.for(topic: event.topic, user: event.user.presence || event.eventable.real_participant)
                          .update_reader(ranges: event.sequence_id, volume: :loud)
    end
  end
end
