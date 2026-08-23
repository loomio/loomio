require 'event_bus'

EventBus.configure do |config|
  config.listen('new_comment_event',
                'new_discussion_event',
                'discussion_edited_event',
                'poll_created_event',
                'poll_edited_event',
                'stance_created_event',
                'outcome_created_event',
                'poll_closed_by_user_event') do |topic_item|
    reader_user = topic_item.user.presence
    reader_user ||= topic_item.itemable.real_participant if topic_item.itemable.respond_to?(:real_participant)

    if topic_item.topic && reader_user
      TopicReader.for(topic: topic_item.topic, user: reader_user)
                 .update_reader(ranges: topic_item.sequence_id, volume: :loud)
    end
  end
end
