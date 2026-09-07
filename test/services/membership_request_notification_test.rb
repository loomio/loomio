require "test_helper"

class MembershipRequestNotificationTest < ActiveSupport::TestCase
  setup do
    @actor = users(:admin)
    @group = groups(:group)
    @group.update!(is_visible_to_public: true)
    memberships(:admin_membership).update!(volume_email: "normal")
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
    RouteNotificationDeliveriesWorker.perform_now(notification.id)

    assert_includes notification.notification_deliveries.where(channel: "in_app").pluck(:recipient_id), @actor.id
    assert_includes notification.notification_deliveries.where(channel: "email").pluck(:recipient_id), @actor.id
  end

  test "requesting membership without an account name identifies the requestor by email" do
    requestor = User.create!(email: "nameless-#{SecureRandom.hex(4)}@example.com", email_verified: true)
    request = MembershipRequest.new(group: @group, introduction: "Please let me join")

    assert_equal request, MembershipRequestService.create(
      membership_request: request,
      actor: requestor
    )

    notification = Notification.find_by!(
      kind: "membership_requested",
      subject: request
    )
    assert_equal requestor.email, notification.translation_values["name"]
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
    RouteNotificationDeliveriesWorker.perform_now(notification.id)

    assert_equal %w[email in_app], notification.notification_deliveries.order(:channel).pluck(:channel)
    assert_equal [ @requestor.id ], notification.notification_deliveries.distinct.pluck(:recipient_id)
  end

  test "approving membership falls back to the group title when its translation has no title field" do
    @actor.update!(selected_locale: "pl", auto_translate: true)
    @group.update_columns(content_locale: "en")
    Translation.create!(
      translatable: @group,
      language: "pl",
      fields: { "name" => "Przetłumaczona nazwa grupy" }
    )
    request = MembershipRequest.create!(group: @group, requestor: @requestor)

    TranslationService.stub(:available?, true) do
      assert_equal request, MembershipRequestService.approve(
        membership_request: request,
        actor: @actor
      )
    end

    membership = Membership.find_by!(group: @group, user: @requestor)
    notification = Notification.find_by!(
      kind: "membership_request_approved",
      subject: membership
    )
    assert_equal @group.full_name, notification.translation_values["title"]
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
