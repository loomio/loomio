require "test_helper"
require_relative "../support/access_volume_matrix"

class CleanupDeliveryMatrixTest < ActiveSupport::TestCase
  test "cleanup and read-range repair preserve the exact in-app email and push audiences" do
    subscriptions = AccessVolumeMatrix::ROLES.to_h do |role|
      [ role, create_push_subscription(user: users(role), endpoint: "https://fcm.googleapis.com/fcm/send/cleanup-#{role}", p256dh_key: "key", auth_key: "auth") ]
    end
    normal = %i[user member member_normal guest_normal guest_admin_normal reader_normal]
    loud = %i[member_loud guest_loud reader_loud member_guest_loud former_member_guest]
    matrix = {
      discussion_topic: {
        actor: :admin,
        in_app: normal + loud + %i[member_quiet guest_quiet reader_quiet],
        email: normal + loud,
        push: normal + %i[member_loud guest_quiet reader_quiet member_guest_loud former_member_guest]
      },
      direct_topic: {
        actor: :guest_admin_normal,
        in_app: %i[guest_quiet guest_normal guest_loud],
        email: %i[guest_normal guest_loud],
        push: %i[guest_normal guest_quiet]
      }
    }

    %i[baseline orphan_cleanup inactive_cleanup].each do |phase|
      case phase
      when :orphan_cleanup
        CleanupService.delete_orphan_records
      when :inactive_cleanup
        CleanupService.delete_inactive_orphan_users
      end

      matrix.each do |topic_name, expected|
        notification = Notification.create!(
          kind: "discussion_edited", subject: topics(topic_name).topicable,
          actor: users(expected[:actor]), recipient_user_ids: AccessVolumeMatrix::ROLES.map { |role| users(role).id }
        )
        NotificationDeliveryRouter.for(notification).route!

        %i[in_app email push].each do |channel|
          recipient_type = channel == :push ? "PushSubscription" : "User"
          ids = expected.fetch(channel).map { |role| channel == :push ? subscriptions.fetch(role).id : users(role).id }
          actual = notification.notification_deliveries.where(channel: channel, recipient_type: recipient_type).pluck(:recipient_id)
          assert_equal ids.sort, actual.sort, "#{phase} / #{topic_name} / #{channel}"
        end
      end
    end
  end
end
