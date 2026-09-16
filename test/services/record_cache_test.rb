require 'test_helper'

class RecordCacheTest < ActiveSupport::TestCase
  def capture_sql
    queries = []
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |_name, _started, _finished, _id, payload|
      queries << payload[:sql] unless payload[:name] == 'SCHEMA' || payload[:cached]
    end
    yield
    queries
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end

  test 'for empty collection returns an empty cache without queries' do
    user_id = users(:admin).id
    queries = capture_sql do
      @cache = RecordCache.for_collection([], user_id)
    end

    assert_empty @cache.scope
    assert_empty queries
  end

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
    reader = TopicReader.new(topic: topic, user: users(:admin), volume_email: 'normal')

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

  test 'add topic readers records missing topics as cached nil' do
    cache = RecordCache.new
    topic_ids = [topics(:discussion_topic).id, topics(:public_discussion_topic).id]

    cache.add_topic_readers([], topic_ids: topic_ids)

    assert_nil cache.scope[:topic_readers_by_topic_id][topic_ids.first]
    assert_nil cache.scope[:topic_readers_by_topic_id][topic_ids.last]
    assert cache.scope[:topic_readers_by_topic_id].key?(topic_ids.first)
    assert cache.scope[:topic_readers_by_topic_id].key?(topic_ids.last)
  end

  test 'add outcomes indexes latest outcomes and records polls without outcomes' do
    poll_ids = [101, 102]
    outcome = Outcome.new(id: 201, poll_id: poll_ids.first, author_id: users(:admin).id, latest: true)
    cache = RecordCache.new

    cache.add_outcomes([outcome], poll_ids: poll_ids)

    assert_equal outcome, cache.scope[:outcomes_by_id][outcome.id]
    assert_equal outcome, cache.scope[:outcomes_by_poll_id][poll_ids.first]
    assert cache.scope[:outcomes_by_poll_id].key?(poll_ids.last)
    assert_nil cache.scope[:outcomes_by_poll_id][poll_ids.last]
  end

  test 'add polls options stances and outcomes builds serializer indexes' do
    poll = Poll.new(id: 301, topic_id: topics(:discussion_topic).id, author_id: users(:admin).id)
    option = PollOption.new(id: 302, poll_id: poll.id, name: 'Agree')
    stance = Stance.new(id: 303, poll_id: poll.id, participant_id: users(:user).id, latest: true)
    outcome = Outcome.new(id: 304, poll_id: poll.id, author_id: users(:admin).id, latest: true)
    cache = RecordCache.new
    cache.current_user_id = users(:user).id

    PollOption.stub(:where, [option]) do
      Stance.stub(:latest, Stance) do
        Stance.stub(:where, [stance]) do
          Outcome.stub(:latest, Outcome) do
            Outcome.stub(:where, [outcome]) do
              cache.add_polls_options_stances_outcomes([poll])
            end
          end
        end
      end
    end

    assert_equal poll, cache.scope[:polls_by_id][poll.id]
    assert_equal [poll], cache.scope[:polls_by_topic_id][poll.topic_id]
    assert_equal option, cache.scope[:poll_options_by_id][option.id]
    assert_equal [option], cache.scope[:poll_options_by_poll_id][poll.id]
    assert_equal stance, cache.scope[:my_stances_by_poll_id][poll.id]
    assert_equal outcome, cache.scope[:outcomes_by_poll_id][poll.id]
  end

  test 'add undecided voter ids batches voters by poll and caches missing results' do
    included_poll = Poll.new(id: 351)
    excluded_poll = Poll.new(id: 352)
    included_poll.define_singleton_method(:detached_anonymous?) { false }
    included_poll.define_singleton_method(:results_include_undecided) { true }
    excluded_poll.define_singleton_method(:detached_anonymous?) { true }
    excluded_poll.define_singleton_method(:results_include_undecided) { true }
    relation = Object.new
    relation.define_singleton_method(:undecided) { self }
    relation.define_singleton_method(:where) { |**| self }
    relation.define_singleton_method(:pluck) { |*| [[351, 10], [351, 11]] }
    cache = RecordCache.new

    Stance.stub(:latest, relation) do
      cache.add_undecided_voter_ids([included_poll, excluded_poll])
    end

    assert_equal [10, 11], cache.scope[:undecided_voter_ids_by_poll_id][included_poll.id]
    assert cache.scope[:undecided_voter_ids_by_poll_id].key?(excluded_poll.id)
    assert_nil cache.scope[:undecided_voter_ids_by_poll_id][excluded_poll.id]
  end

  test 'excluded types do not create their cache indexes' do
    cache = RecordCache.new
    cache.exclude_types = %w[poll poll_option stance outcome reaction]
    poll = Poll.new(id: 401, topic_id: topics(:discussion_topic).id, author_id: users(:admin).id)

    cache.add_polls_options_stances_outcomes([poll])
    cache.add_reactions_for_itemables([discussions(:discussion)])

    assert_empty cache.scope
  end

  test 'add reactions stores reactions by id and tracks reaction users' do
    discussion = discussions(:discussion)
    reaction = Reaction.create!(reactable: discussion, user: users(:alien), reaction: '❤️')
    cache = RecordCache.new

    cache.add_reactions([reaction])

    assert_equal reaction, cache.scope[:reactions_by_id][reaction.id]
    assert_includes cache.scope[:reactions_by_reactable_type_and_id]['Discussion'][discussion.id], reaction
    assert_equal users(:alien), cache.scope[:users_by_id][users(:alien).id] if cache.scope[:users_by_id]
  end

  test 'for topic_item collection caches itemables' do
    topic_item = topic_items(:discussion_created_topic_item)
    discussion = discussions(:discussion)

    cache = RecordCache.for_collection([topic_item], users(:admin).id)

    assert_equal topic_item, cache.scope[:topic_items_by_id][topic_item.id]
    assert_equal discussion, cache.scope[:discussions_by_id][discussion.id]
  end

  test 'for topic collection caches polymorphic topicables without loading associations' do
    records = [topics(:discussion_topic), topics(:trial_cleanup_poll)]

    cache = RecordCache.for_collection(records, users(:admin).id)

    assert_equal discussions(:discussion), cache.scope[:discussions_by_id][discussions(:discussion).id]
    assert_equal polls(:trial_cleanup_poll), cache.scope[:polls_by_id][polls(:trial_cleanup_poll).id]
    assert records.none? { |topic| topic.association(:topicable).loaded? }
  end

  test 'for topic collection uses batched topicable queries' do
    records = [
      topics(:discussion_topic),
      topics(:public_discussion_topic),
      topics(:alien_discussion_topic),
      topics(:trial_cleanup_poll)
    ]

    queries = capture_sql do
      RecordCache.for_collection(records, users(:admin).id, ['reaction'])
    end

    point_topicable_queries = queries.select do |sql|
      sql.match?(/FROM "(?:discussions|polls)" WHERE .+"id" = \$1 LIMIT \$2/)
    end
    assert_empty point_topicable_queries
  end

  test 'for discussion collection loads reactions once' do
    queries = capture_sql do
      RecordCache.for_collection([discussions(:discussion)], users(:admin).id)
    end

    reaction_queries = queries.select { |sql| sql.include?('FROM "reactions"') }
    assert_equal 1, reaction_queries.length
  end

  test 'for topic collection loads discussion reactions once' do
    queries = capture_sql do
      RecordCache.for_collection([topics(:discussion_topic)], users(:admin).id)
    end

    reaction_queries = queries.select { |sql| sql.include?('FROM "reactions"') }
    assert_equal 1, reaction_queries.length
  end

  test 'for group collection caches parent groups memberships and subscriptions' do
    cache = RecordCache.for_collection([groups(:subgroup)], users(:user).id)

    assert_equal groups(:subgroup), cache.scope[:groups_by_id][groups(:subgroup).id]
    assert_equal groups(:group), cache.scope[:groups_by_id][groups(:group).id]
    assert_equal memberships(:user_subgroup_membership), cache.scope[:memberships_by_group_id][groups(:subgroup).id]
    assert cache.scope[:memberships_by_group_id].key?(groups(:group).id)
    assert cache.scope[:subscriptions_by_group_id].key?(groups(:subgroup).id)
  end

  test 'for poll collection caches topics without loading associations' do
    poll = polls(:trial_cleanup_poll)
    poll.update_column(:topic_id, topics(:trial_cleanup_poll).id)
    records = [poll]

    cache = RecordCache.for_collection(records, users(:admin).id)

    assert_equal topics(:trial_cleanup_poll), cache.scope[:topics_by_id][topics(:trial_cleanup_poll).id]
    assert_not poll.association(:topic).loaded?
  end
end
