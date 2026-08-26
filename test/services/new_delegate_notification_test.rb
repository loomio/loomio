require "test_helper"

class NewDelegateNotificationTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @actor = users(:admin)
    @membership = memberships(:member_membership)
    @membership.update!(volume: "normal")
    @membership.user.update!(email_verified: true)
  end

  test "making a delegate creates in-app and email notification deliveries" do
    assert_equal @membership, MembershipService.make_delegate(
      membership: @membership,
      actor: @actor
    )

    notification = Notification.find_by!(
      kind: "new_delegate",
      subject: @membership
    )
    ResolveNotificationDeliveriesWorker.perform_now(notification.id)

    assert @membership.reload.delegate?
    assert_equal %w[email in_app], notification.notification_deliveries.order(:channel).pluck(:channel)

    delivery = notification.notification_deliveries.find_by!(channel: "email")
    assert_difference "ActionMailer::Base.deliveries.count", 1 do
      DeliverNotificationEmailWorker.perform_now(delivery.id)
    end
    assert_includes ActionMailer::Base.deliveries.last.to, @membership.user.email
  end

  test "quiet delegates retain in-app delivery without email" do
    @membership.update!(volume: "quiet")
    MembershipService.make_delegate(membership: @membership, actor: @actor)
    notification = Notification.find_by!(
      kind: "new_delegate",
      subject: @membership
    )

    ResolveNotificationDeliveriesWorker.perform_now(notification.id)

    assert_equal [ "in_app" ], notification.notification_deliveries.pluck(:channel)
  end
end
