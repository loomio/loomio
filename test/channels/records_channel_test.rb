require 'test_helper'
require 'action_cable/channel/test_case'

class RecordsChannelTest < ActionCable::Channel::TestCase
  tests RecordsChannel

  setup do
    @member = users(:member_normal)
    @group = groups(:group)
    stub_connection current_user: @member
  end

  test "revocation stops private group streams while retaining the user stream" do
    subscribe
    assert_has_stream "group_#{@group.id}"
    payload = {'membership_access' => {'group_ids' => [@group.id], 'revoked' => true}}

    subscription.send(:receive_user_payload, payload)

    assert_has_stream "user_#{@member.id}"
    assert_has_no_stream "group_#{@group.id}"
    assert_equal payload, transmissions.last
  end

  test "restoring streams requires current membership even if group IDs were cached" do
    subscribe
    membership = @group.membership_for(@member)
    membership.update!(revoked_at: Time.current)
    subscription.send(:receive_user_payload, {'membership_access' => {'group_ids' => [@group.id], 'revoked' => true}})
    restore = {'membership_access' => {'group_ids' => [@group.id, groups(:alien_group).id], 'revoked' => false}}

    subscription.send(:receive_user_payload, restore)
    assert_has_no_stream "group_#{@group.id}"
    assert_has_no_stream "group_#{groups(:alien_group).id}"

    membership.update!(revoked_at: nil)
    subscription.send(:receive_user_payload, restore)
    assert_has_stream "group_#{@group.id}"
    assert_has_no_stream "group_#{groups(:alien_group).id}"
  end
end
