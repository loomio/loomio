require 'test_helper'

class RecordCountsTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @group = Group.create!(name: 'Counted group', group_privacy: 'secret')
    @group.add_admin!(@admin)
  end

  test 'membership title delivery and weight changes do no owner count work' do
    membership = @group.add_member!(users(:alien))
    queries = capture_sql do
      membership.update!(title: 'Treasurer', volume_email: :quiet, volume_push: :loud, weight: 2)
    end

    assert_empty queries.grep(/UPDATE\s+"?(?:groups|users)"?\s|COUNT\(.*FROM\s+"?memberships/i)
    assert_equal [2, 0, 1], group_membership_counts
  end

  test 'a write lock does not restrict nested recounts to its owner' do
    destination = Group.create!(name: 'Nested recount', group_privacy: 'secret')
    membership = Membership.create!(group: destination, user: users(:alien))
    Membership.where(id: membership.id).update_all(accepted_at: Time.current, admin: true)

    Group.where(id: @group.id).with_write_lock(:id) do
      destination.update_membership_counts
    end

    assert_equal [1, 0, 1], destination.reload.attributes.values_at('memberships_count', 'pending_memberships_count', 'admin_memberships_count')
  end

  test 'acceptance promotion revocation and restoration change only their contributions' do
    membership = Membership.create!(group: @group, user: users(:alien))
    assert_equal [2, 1, 1], group_membership_counts
    membership.update!(accepted_at: Time.current, admin: true)
    assert_equal [2, 0, 2], group_membership_counts
    membership.update!(revoked_at: Time.current)
    assert_equal [1, 0, 1], group_membership_counts
    membership.update!(revoked_at: nil)
    assert_equal [2, 0, 2], group_membership_counts
    assert_equal membership.user.memberships.count, membership.user.reload.memberships_count
  end

  test 'deletion removes the stored membership contribution despite unsaved edits' do
    destination = Group.create!(name: 'Unsaved membership destination', group_privacy: 'secret')
    original_user = users(:alien)
    destination_user = users(:member)
    original_user_count = original_user.reload.memberships_count
    destination_user_count = destination_user.reload.memberships_count
    membership = Membership.create!(group: @group, user: original_user, admin: true)
    membership.assign_attributes(group: destination, user: destination_user, revoked_at: Time.current, admin: false)

    membership.destroy!

    assert_equal [1, 0, 1], group_membership_counts
    assert_equal [0, 0, 0], destination.reload.attributes.values_at('memberships_count', 'pending_memberships_count', 'admin_memberships_count')
    assert_equal original_user_count, original_user.reload.memberships_count
    assert_equal destination_user_count, destination_user.reload.memberships_count
    assert_equal 1, @group.reload.org_members_count
    assert_equal 0, destination.org_members_count
  end

  test 'organization totals count a person once across subgroup memberships' do
    child = Group.create!(name: 'Counted child', parent: @group, group_privacy: 'secret')
    other = Group.create!(name: 'Other organization', group_privacy: 'secret')
    child.add_member!(@admin)
    membership = child.add_member!(users(:alien))
    assert_equal 2, @group.reload.org_members_count

    child.update!(parent: other)
    assert_equal 1, @group.reload.org_members_count
    assert_equal 2, other.reload.org_members_count
    membership.destroy!
    assert_equal 1, other.reload.org_members_count
  end

  test 'group serialization queries kept subgroups after discard and restoration' do
    child = Group.create!(name: 'Kept child', parent: @group, group_privacy: 'secret')
    child.discard!
    assert_equal 0, GroupSerializer.new(@group).subgroups_count
    child.undiscard!
    assert_equal 1, GroupSerializer.new(@group).subgroups_count
    child.update!(name: 'Renamed child')
    assert_equal 1, GroupSerializer.new(@group).subgroups_count
  end

  test 'subgroup serialization batches queries including zero counts' do
    other = groups(:alien_group)
    Group.create!(name: 'Queried subgroup', parent: @group, group_privacy: 'secret')
    collection = [@group, other]
    serialized_counts = nil
    queries = capture_sql do
      cache = RecordCache.for_collection(collection, @admin.id)
      assert_no_record_cache_fallbacks do
        serialized_counts = collection.map { |group| GroupSerializer.new(group, scope: { cache: cache }).subgroups_count }
      end
    end
    assert_equal [1, 0], serialized_counts
    assert_equal 1, queries.grep(/GROUP BY "groups"\."parent_id"/).length
  end

  test 'reading a topic repeatedly changes its seen count only on the first read' do
    topic = topics(:discussion_topic)
    reader = TopicReader.find_or_create_for!(user: users(:alien), topic: topic)
    count_before = topic.reload.seen_by_count
    reader.viewed!(0)
    assert_equal count_before + 1, topic.reload.seen_by_count

    queries = capture_sql { reader.viewed!(0) }
    assert_empty queries.grep(/UPDATE\s+"?topics"?\s|COUNT\(.*FROM\s+"?topic_readers/i)
    reader.update!(revoked_at: Time.current)
    assert_equal count_before + 1, topic.reload.seen_by_count
    reader.destroy!
    assert_equal count_before, topic.reload.seen_by_count
  end

  test 'poll opening closing discard and restoration maintain active topic counts' do
    poll = PollService.create(params: poll_params.merge(group_id: @group.id, opening_at: 1.day.from_now,
                                                       closing_at: 2.days.from_now), actor: @admin)
    assert_equal 0, poll.topic.reload.active_polls_count
    poll.update!(opened_at: Time.current)
    assert_equal 1, poll.topic.reload.active_polls_count
    poll.update!(closed_at: Time.current)
    assert_equal 0, poll.topic.reload.active_polls_count
    poll.update!(closed_at: nil)
    assert_equal 1, poll.topic.reload.active_polls_count
    poll.discard!
    assert_equal 0, poll.topic.reload.active_polls_count
    poll.undiscard!
    assert_equal 1, poll.topic.reload.active_polls_count
  end

  test 'moving a topic transfers its content counts including the direct path' do
    discussion = new_discussion
    PollService.create(params: poll_params.merge(topic_id: discussion.topic_id), actor: @admin)
    destination = Group.create!(name: 'Content destination', group_privacy: 'secret')
    assert_equal [1, 1], @group.reload.attributes.values_at('discussions_count', 'polls_count')

    discussion.topic.update!(group: destination)
    assert_equal [0, 0], @group.reload.attributes.values_at('discussions_count', 'polls_count')
    assert_equal [1, 1], destination.reload.attributes.values_at('discussions_count', 'polls_count')
    discussion.topic.update!(group_id: nil)
    assert_equal [0, 0], destination.reload.attributes.values_at('discussions_count', 'polls_count')
    discussion.topic.destroy!
    assert_equal [0, 0], @group.reload.attributes.values_at('discussions_count', 'polls_count')
  end

  test 'title edits do not recount group or topic poll counts' do
    discussion = new_discussion
    poll = PollService.create(params: poll_params.merge(topic_id: discussion.topic_id), actor: @admin)
    queries = capture_sql do
      discussion.update!(title: 'Updated thread')
      poll.update!(title: 'Updated poll')
    end

    assert_empty queries.grep(/UPDATE\s+"?(?:groups|topics)"?\s|COUNT\(.*FROM\s+"?(?:polls|discussions)/i)
    assert_equal discussion.versions.count, discussion.reload.versions_count
  end

  test 'discarding a thread with several polls resets its active count' do
    discussion = new_discussion
    discussion.topic.update!(allow_concurrent_polls: true)
    2.times { PollService.create(params: poll_params.merge(topic_id: discussion.topic_id), actor: @admin) }
    assert_equal 2, discussion.topic.reload.active_polls_count

    TopicService.discard(topic: discussion.topic, actor: @admin)

    assert_equal 0, discussion.topic.reload.active_polls_count
    assert_equal 0, @group.reload.discussions_count
  end

  test 'reply insertion increments the parent without counting its children' do
    discussion = new_discussion
    parent = CommentService.create(comment: Comment.new(parent: discussion, body: 'Parent'), actor: @admin)
    queries = capture_sql do
      CommentService.create(comment: Comment.new(parent: parent, body: 'Reply'), actor: @admin)
    end

    assert_empty queries.grep(/SELECT.*COUNT\(.*FROM\s+"?topic_items/i)
    assert_equal 1, parent.created_topic_item.child_count
  end

  test 'identical increments execute each time with the Rails query cache enabled' do
    ActiveRecord::Base.cache do
      Membership.create!(group: @group, user: users(:alien))
      Membership.create!(group: @group, user: users(:member))
    end

    assert_equal [3, 2, 1], group_membership_counts
  end

  test 'bulk revocation and reinvitation refresh every related membership count' do
    user = users(:alien)
    membership = Membership.create!(group: @group, user: user, admin: true, accepted_at: Time.current)
    MembershipService.revoke(membership: membership, actor: @admin)
    assert_equal [1, 0, 1], group_membership_counts
    assert_equal user.memberships.count, user.reload.memberships_count

    GroupService.invite(group: @group, actor: @admin, params: { recipient_emails: [user.email] })
    assert_equal [2, 1, 1], group_membership_counts
    assert_equal user.memberships.count, user.reload.memberships_count
  end

  test 'account reactivation rebuilds admin pending and user counts as well as total members' do
    user = users(:alien)
    Membership.create!(group: @group, user: user, admin: true)
    time = Time.current
    MembershipService.revoke_by_id([@group.id], user.id, @admin.id, time)
    user.update!(deactivated_at: time)

    UserService.reactivate(user.id)

    assert_equal [2, 1, 2], group_membership_counts
    assert_equal user.memberships.count, user.reload.memberships_count
  end

  test 'group merge rebuilds counts for bulk moved content memberships and subgroups' do
    source = @group
    source.add_member!(users(:alien))
    target = Group.create!(name: 'Merge target', group_privacy: 'secret')
    target.add_admin!(@admin)
    Group.create!(name: 'Merged subgroup', parent: source, group_privacy: 'secret')
    discussion = new_discussion
    PollService.create(params: poll_params.merge(topic_id: discussion.topic_id), actor: @admin)

    GroupService.merge(source: source, target: target, actor: @admin)

    target.reload
    assert_equal target.memberships.count, target.memberships_count
    assert_equal target.memberships.pending.count, target.pending_memberships_count
    assert_equal target.admin_memberships.count, target.admin_memberships_count
    assert_equal [1, 1], target.attributes.values_at('discussions_count', 'polls_count')
    assert_equal 1, GroupSerializer.new(target).subgroups_count
    assert_equal @admin.memberships.count, @admin.reload.memberships_count
    assert_equal target.id, discussion.topic.reload.group_id
  end

  test 'deleting a reply parent promotes its children and changes the ancestor by children minus one' do
    discussion = new_discussion
    discussion.topic.update!(max_depth: 10)
    parent = CommentService.create(comment: Comment.new(parent: discussion, body: 'Parent'), actor: @admin)
    replies = 2.times.map do
      CommentService.create(comment: Comment.new(parent: parent, body: 'Reply'), actor: @admin)
    end
    root = discussion.created_topic_item
    assert_equal 1, root.child_count

    parent.created_topic_item.destroy!

    assert_equal 2, root.reload.child_count
    assert_equal replies.map { |reply| reply.created_topic_item.id }.sort, root.children.pluck(:id).sort
    TopicService.verify_integrity!(discussion.topic_id)
  end

  private

  def capture_sql
    queries = []
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |*, payload|
      queries << payload[:sql] unless payload[:name] == 'SCHEMA' || payload[:cached]
    end
    yield
    queries
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end

  def group_membership_counts
    @group.reload.attributes.values_at('memberships_count', 'pending_memberships_count', 'admin_memberships_count')
  end

  def new_discussion
    DiscussionService.create(params: { title: 'Counted discussion', group_id: @group.id }, actor: @admin)
  end

  def poll_params
    { title: 'Counted poll', poll_type: 'proposal', poll_option_names: %w[agree disagree], closing_at: 1.day.from_now }
  end
end
