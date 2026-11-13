require "test_helper"

class GroupSerializerTest < ActiveSupport::TestCase
  SUBSCRIPTION_KEYS = %i[state expires_at max_members max_threads allow_subgroups allow_guests plan members_count].sort.freeze

  test "subscription fields are consistent for members guests former members visitors and shared payloads" do
    collection = groups(:group, :subgroup, :public_group, :alien_group)
    roles = %i[member_normal guest_normal guest_admin_normal former_member_loud alien server_admin] + [nil]
    roles.each do |role|
      user_id = role && users(role).id
      cache = RecordCache.for_collection(collection, user_id, ['user'])
      json = ActiveModel::ArraySerializer.new(collection, each_serializer: GroupSerializer, root: :groups,
        scope: {cache: cache, current_user_id: user_id, exclude_types: ['user']}).as_json
      json.fetch(:groups).each do |row|
        assert_equal SUBSCRIPTION_KEYS, row.fetch(:subscription).keys.sort, role.to_s
      end
    end
  end

  test "group serialization reuses hydrated parents without querying viewer permissions" do
    user = users(:member_normal)
    collection = groups(:group, :subgroup, :subgroup_other)
    cache = RecordCache.for_collection(collection, user.id, ['user'])
    queries = []
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |_name, _start, _finish, _id, payload|
      queries << payload[:sql] unless payload[:name] == 'SCHEMA'
    end
    ActiveModel::ArraySerializer.new(collection, each_serializer: GroupSerializer, root: :groups,
      scope: {cache: cache, current_user_id: user.id, exclude_types: ['user']}).as_json

    assert_empty queries.select { |sql| sql.include?('FROM "users"') && sql.include?('"is_admin"') }
    assert_empty queries.select { |sql| sql.start_with?('SELECT "groups".*') }
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end

  test "visitors get the explicit subscription field set without billing identifiers or account details" do
    group = groups(:public_group)
    expires_at = 3.days.from_now.change(usec: 0)
    renews_at = 30.days.from_now.change(usec: 0)
    group.update!(subscription: Subscription.create!(
      owner: users(:admin), plan: "pro", state: "past_due", expires_at: expires_at, renews_at: renews_at,
      max_members: 50, max_threads: 100, members_count: 12, allow_guests: false, allow_subgroups: false,
      billing_service_subscription_id: "private-subscription", info: {chargify_management_link: "private-link"}
    ))

    payload = GroupSerializer.new(group, scope: { exclude_types: [] }).as_json.fetch(:group)

    assert_equal({
      state: "past_due", expires_at: expires_at, max_members: 50, max_threads: 100,
      allow_guests: false, allow_subgroups: false, plan: "pro", members_count: 12
    }, payload[:subscription])
    assert_not payload.key?(:enabled)

    group.update!(subscription: nil)
    payload = GroupSerializer.new(group.reload, scope: { exclude_types: [] }).as_json.fetch(:group)
    assert_equal({
      state: "active", expires_at: nil, max_members: nil, max_threads: nil,
      allow_guests: true, allow_subgroups: true, plan: "free", members_count: nil
    }, payload[:subscription])
  end

  test "shared payloads omit follow state instead of reporting false" do
    group = groups(:public_group)
    user = users(:user)
    GroupFollow.create!(group: group, user: user)

    shared = GroupSerializer.new(group, scope: { exclude_types: [] }).as_json.fetch(:group)
    assert_not shared.key?(:current_user_followed)

    personal = GroupSerializer.new(group, scope: { exclude_types: [], current_user_id: user.id }).as_json.fetch(:group)
    assert_equal true, personal[:current_user_followed]
  end
end
