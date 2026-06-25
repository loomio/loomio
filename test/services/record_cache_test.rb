require 'test_helper'

class RecordCacheTest < ActiveSupport::TestCase
  test 'fetch returns cached nil without yielding' do
    cache = RecordCache.new
    cache.scope[:memberships_by_group_id] = { 1 => nil }

    yielded = false
    result = cache.fetch(:memberships_by_group_id, 1) do
      yielded = true
      :fallback
    end

    assert_nil result
    assert_not yielded
  end

  test 'fetch yields when id is not cached' do
    cache = RecordCache.new
    cache.scope[:users_by_id] = {}

    assert_equal :fallback, cache.fetch(:users_by_id, 1) { :fallback }
  end

  test 'fetch supports nested keys' do
    cache = RecordCache.new
    cache.scope[:tags_by_type_and_id] = {
      'Group' => {
        1 => [:tag]
      }
    }

    assert_equal [:tag], cache.fetch([:tags_by_type_and_id, 'Group'], 1)
  end

  test 'add users stores users by id' do
    cache = RecordCache.new
    user = users(:admin)

    cache.add_users([user])

    assert_equal user, cache.scope[:users_by_id][user.id]
  end

  test 'add topic readers stores readers by topic id' do
    cache = RecordCache.new
    topic = topics(:discussion_topic)
    reader = TopicReader.new(topic: topic, user: users(:admin), volume: 'normal')

    cache.add_topic_readers([reader])

    assert_equal reader, cache.scope[:topic_readers_by_topic_id][topic.id]
  end

  test 'indexed caches merge instead of replacing existing records' do
    cache = RecordCache.new
    first = discussions(:discussion)
    second = discussions(:alien_discussion)

    cache.add_discussions([first])
    cache.add_discussions([second])

    assert_equal first, cache.scope[:discussions_by_id][first.id]
    assert_equal second, cache.scope[:discussions_by_id][second.id]
  end

  test 'ids and parent ids compacts nil values' do
    group = groups(:group)

    assert_equal [group.id], RecordCache.ids_and_parent_ids(Group, [group.id, nil])
  end

  test 'known missing cache keys are explicitly limited' do
    cache = RecordCache.new

    assert_raises ArgumentError do
      cache.add_known_missing(:discussions_by_id, [1])
    end
  end

  test 'add reactions stores reactions by id and tracks reaction users' do
    discussion = discussions(:discussion)
    reaction = Reaction.create!(reactable: discussion, user: users(:alien), reaction: ':heart:')
    cache = RecordCache.new

    cache.add_reactions([reaction])

    assert_equal reaction, cache.scope[:reactions_by_id][reaction.id]
    assert_includes cache.scope[:reactions_by_reactable_type_and_id]['Discussion'][discussion.id], reaction
    assert_equal users(:alien), cache.scope[:users_by_id][users(:alien).id] if cache.scope[:users_by_id]
  end

  test 'for event collection caches eventables' do
    event = events(:discussion_created_event)
    discussion = discussions(:discussion)

    cache = RecordCache.for_collection([event], users(:admin).id)

    assert_equal event, cache.scope[:events_by_id][event.id]
    assert_equal discussion, cache.scope[:discussions_by_id][discussion.id]
  end
end
