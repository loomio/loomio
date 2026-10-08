require 'test_helper'

class TopicReaderSerializerTest < ActiveSupport::TestCase
  setup do
    @topic = topics(:discussion_topic)
    @reader = topic_readers(:reader_normal_reader)
    @reader.update!(last_read_at: 1.hour.ago, read_ranges_string: '0-0')
    @poll = PollService.create(params: {
      title: 'Anonymous reading history', poll_type: 'proposal', topic_id: @topic.id,
      anonymous: true, poll_option_names: %w[agree disagree], closing_at: 1.day.from_now
    }, actor: users(:admin))
    @topic.update_column(:anonymous_polls_count, 0)
  end

  test 'anonymous reading history stays hidden despite a stale stored count for every viewer role' do
    viewers = [LoggedOutUser.new] + users(:user, :admin, :alien, :guest_normal, :guest_admin_normal,
                                          :former_member_loud, :inactive_member_loud)
    viewers.each do |viewer|
      serializer = TopicReaderSerializer.new(@reader, scope: { current_user_id: viewer.id })
      assert_nil serializer.last_read_at, viewer.class.name
      assert_empty serializer.read_ranges, viewer.class.name
    end
    assert_equal 1, TopicSerializer.new(@topic).anonymous_polls_count
  end

  test 'closing or discarding an anonymous poll does not expose reading history' do
    @poll.update!(closed_at: Time.current)
    @poll.discard!

    serializer = TopicReaderSerializer.new(@reader)
    assert_nil serializer.last_read_at
    assert_empty serializer.read_ranges
  end

  test 'moving an anonymous poll updates privacy from actual topic ownership' do
    destination = topics(:public_discussion_topic)
    @poll.update!(topic: destination)

    serializer = TopicReaderSerializer.new(@reader.reload)
    assert_equal @reader.last_read_at, serializer.last_read_at
    assert_equal @reader.read_ranges, serializer.read_ranges
    assert_equal 0, TopicSerializer.new(@topic).anonymous_polls_count
    assert_equal 1, TopicSerializer.new(destination).anonymous_polls_count
  end

  test 'reader lists batch anonymous poll queries and share the masking result' do
    readers = @topic.topic_readers.to_a
    counts = []
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |*, payload|
      counts << payload[:sql] if payload[:sql].match?(/SELECT.*COUNT.*FROM "polls"/i)
    end
    cache = RecordCache.for_collection(readers, users(:admin).id)

    assert_no_record_cache_fallbacks do
      readers.each do |reader|
        serializer = TopicReaderSerializer.new(reader, scope: { cache: cache })
        assert_nil serializer.last_read_at
        assert_empty serializer.read_ranges
      end
    end
    assert_equal 1, counts.length
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end

  test 'direct topics without anonymous polls preserve their readers own state' do
    reader = topic_readers(:direct_guest_normal_reader)
    reader.update!(last_read_at: Time.current, read_ranges_string: '1-1')

    serializer = TopicReaderSerializer.new(reader)
    assert_equal reader.last_read_at, serializer.last_read_at
    assert_equal reader.read_ranges, serializer.read_ranges
  end
end
