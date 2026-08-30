require "test_helper"

class NewCoordinatorNotificationTest < ActiveSupport::TestCase
  inline_jobs

  setup do
    @actor = users(:admin)
    @membership = memberships(:member_membership)
    @membership.update!(volume_email: :normal)
    @membership.user.update!(email_verified: true)
  end

  test "making a coordinator creates in-app and email notification deliveries" do
    notification = nil

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

    assert @membership.reload.admin?
    assert_equal %w[email in_app], notification.notification_deliveries.order(:channel).pluck(:channel)
    delivery = notification.notification_deliveries.find_by!(channel: "in_app")
    assert_equal @membership.user, delivery.recipient
    assert_not_nil delivery.delivered_at
  end

  test "quiet coordinators retain in-app delivery without email" do
    @membership.update!(volume_email: :quiet)
    MembershipService.make_admin(membership: @membership, actor: @actor)
    notification = Notification.find_by!(kind: "new_coordinator", subject: @membership)

    assert_equal [ "in_app" ], notification.notification_deliveries.pluck(:channel)
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
