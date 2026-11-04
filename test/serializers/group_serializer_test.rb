require "test_helper"

class GroupSerializerTest < ActiveSupport::TestCase
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
