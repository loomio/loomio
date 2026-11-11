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
      rows = json.fetch(:groups)
      assert_equal allowed_ids.sort, rows.select { |row| row[:subscription].key?(:plan) }.pluck(:id).sort, role.to_s
      rows.each { |row| assert_equal %i[expires_at state], row[:subscription].keys.first(2).sort, role.to_s }
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

  test "visitors get the raw subscription state but not the plan details" do
    group = groups(:public_group)
    expires_at = 3.days.from_now.change(usec: 0)
    group.update!(subscription: Subscription.create!(plan: "pro", state: "past_due", expires_at: expires_at, max_members: 50))

    payload = GroupSerializer.new(group, scope: { exclude_types: [] }).as_json.fetch(:group)

    assert_equal({state: "past_due", expires_at: expires_at}, payload[:subscription])
    assert_not payload.key?(:enabled)

    group.update!(subscription: nil)
    payload = GroupSerializer.new(group.reload, scope: { exclude_types: [] }).as_json.fetch(:group)
    assert_equal({state: "active", expires_at: nil}, payload[:subscription])
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
