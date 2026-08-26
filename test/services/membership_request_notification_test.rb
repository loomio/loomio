require "test_helper"

class MembershipRequestNotificationTest < ActiveSupport::TestCase
  setup do
    @actor = users(:admin)
    @group = groups(:group)
    @group.update!(is_visible_to_public: true)
    memberships(:admin_membership).update!(volume: "normal")
    hex = SecureRandom.hex(4)
    @requestor = User.create!(
      name: "Requestor #{hex}",
      email: "requestor-#{hex}@example.com",
      username: "requestor-#{hex}",
      email_verified: true
    )
  end

  test "requesting membership notifies eligible admins" do
    request = MembershipRequest.new(group: @group, introduction: "Please let me join")

    assert_equal request, MembershipRequestService.create(
      membership_request: request,
      actor: @requestor
    )

    notification = Notification.find_by!(
      kind: "membership_requested",
      subject: request
    )
    ResolveNotificationDeliveriesWorker.perform_now(notification.id)

    assert_includes notification.notification_deliveries.where(channel: "in_app").pluck(:recipient_id), @actor.id
    assert_includes notification.notification_deliveries.where(channel: "email").pluck(:recipient_id), @actor.id
  end

  test "approving membership notifies the requestor" do
    request = MembershipRequest.create!(group: @group, requestor: @requestor)

    assert_equal request, MembershipRequestService.approve(
      membership_request: request,
      actor: @actor
    )

    membership = Membership.find_by!(group: @group, user: @requestor)
    notification = Notification.find_by!(
      kind: "membership_request_approved",
      subject: membership
    )
    ResolveNotificationDeliveriesWorker.perform_now(notification.id)

    assert_equal %w[email in_app], notification.notification_deliveries.order(:channel).pluck(:channel)
    assert_equal [ @requestor.id ], notification.notification_deliveries.distinct.pluck(:recipient_id)
  end

  test "notification failure rolls back request creation" do
    request = MembershipRequest.new(group: @group)

    assert_raises RuntimeError do
      NotificationService.stub(:create!, ->(**) { raise "notification failed" }) do
        MembershipRequestService.create(membership_request: request, actor: @requestor)
      end
    end

    assert_not request.persisted?
  end

  test "notification failure rolls back approval and membership creation" do
    request = MembershipRequest.create!(group: @group, requestor: @requestor)

    assert_raises RuntimeError do
      NotificationService.stub(:create!, ->(**) { raise "notification failed" }) do
        MembershipRequestService.approve(membership_request: request, actor: @actor)
      end
    end

    assert_nil request.reload.response
    assert_not Membership.exists?(group: @group, user: @requestor)
  end
end
