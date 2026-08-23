require "test_helper"

class NewCoordinatorNotificationTest < ActiveSupport::TestCase
  inline_jobs

  setup do
    @actor = users(:admin)
    @membership = memberships(:member_membership)
  end

  test "making a coordinator creates a direct notification without an topic_item" do
    notification = nil

    assert_no_difference -> { TopicItem.where(kind: "new_coordinator").count } do
      assert_difference -> { Notification.where(kind: "new_coordinator").count }, 1 do
        assert_equal @membership, MembershipService.make_admin(
          membership: @membership,
          actor: @actor
        )
        notification = Notification.find_by!(
          kind: "new_coordinator",
          subject: @membership
        )
      end
    end

    assert @membership.reload.admin?
    delivery = notification.notification_deliveries.find_by!(channel: "in_app")
    assert_equal @membership.user, delivery.recipient
    assert_equal "delivered", delivery.status
  end

  test "notification failure rolls back the coordinator change" do
    assert_raises RuntimeError do
      NotificationService.stub(:create!, ->(**) { raise "notification failed" }) do
        MembershipService.make_admin(membership: @membership, actor: @actor)
      end
    end

    assert_not @membership.reload.admin?
  end
end
