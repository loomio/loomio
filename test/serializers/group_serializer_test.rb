require "test_helper"

class GroupSerializerTest < ActiveSupport::TestCase
  test "subscription visibility follows organisation membership and instance admin access" do
    collection = groups(:group, :subgroup, :public_group, :alien_group)
    expected = {
      member_normal: groups(:group, :subgroup).map(&:id),
      guest_normal: [],
      guest_admin_normal: [],
      former_member_loud: [],
      alien: [groups(:alien_group).id],
      server_admin: collection.map(&:id)
    }
    expected.each do |role, allowed_ids|
      user = users(role)
      cache = RecordCache.for_collection(collection, user.id, ['user'])
      json = ActiveModel::ArraySerializer.new(collection, each_serializer: GroupSerializer, root: :groups,
        scope: {cache: cache, current_user_id: user.id, exclude_types: ['user']}).as_json
      assert_equal allowed_ids.sort, json.fetch(:groups).select { |row| row.key?(:subscription) }.pluck(:id).sort, role.to_s
    end
  end

  test "group serialization reuses hydrated parents and checks admin access once" do
    user = users(:member_normal)
    collection = groups(:group, :subgroup, :subgroup_other)
    cache = RecordCache.for_collection(collection, user.id, ['user'])
    queries = []
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |_name, _start, _finish, _id, payload|
      queries << payload[:sql] unless payload[:name] == 'SCHEMA'
    end
    ActiveModel::ArraySerializer.new(collection, each_serializer: GroupSerializer, root: :groups,
      scope: {cache: cache, current_user_id: user.id, exclude_types: ['user']}).as_json

    assert_equal 1, queries.count { |sql| sql.include?('FROM "users"') && sql.include?('"is_admin"') }
    assert_empty queries.select { |sql| sql.start_with?('SELECT "groups".*') }
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end

  test "enabled state is present even when subscription details are hidden" do
    group = groups(:public_group)
    group.update!(subscription: Subscription.create!(plan: "free", state: "active"))
    serializer = GroupSerializer.new(group, scope: { exclude_types: [] })

    payload = serializer.as_json.fetch(:group)

    assert_equal true, payload[:enabled]
    assert_not payload.key?(:subscription)

    group.subscription.update!(state: "on_hold")
    payload = GroupSerializer.new(group.reload, scope: { exclude_types: [] }).as_json.fetch(:group)
    assert_equal false, payload[:enabled]

    group.update!(subscription: nil)
    payload = GroupSerializer.new(group.reload, scope: { exclude_types: [] }).as_json.fetch(:group)
    assert_equal true, payload[:enabled]
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
