require "test_helper"

class GroupSerializerTest < ActiveSupport::TestCase
  test "availability is present even when subscription details are hidden" do
    group = groups(:public_group)
    group.update!(subscription: Subscription.create!(plan: "free", state: "active"))
    serializer = GroupSerializer.new(group, scope: { exclude_types: [] })

    payload = serializer.as_json.fetch(:group)

    assert_equal true, payload[:available]
    assert_not payload.key?(:subscription)

    group.subscription.update!(state: "on_hold")
    payload = GroupSerializer.new(group.reload, scope: { exclude_types: [] }).as_json.fetch(:group)
    assert_equal false, payload[:available]

    group.update!(subscription: nil)
    payload = GroupSerializer.new(group.reload, scope: { exclude_types: [] }).as_json.fetch(:group)
    assert_equal true, payload[:available]
  end
end
