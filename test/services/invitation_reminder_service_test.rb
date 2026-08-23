require "test_helper"

class InvitationReminderServiceTest < ActiveSupport::TestCase
  inline_jobs

  setup do
    @admin = users(:admin)
    @group = groups(:group)
    @invitee = User.create!(
      name: "Reminder invitee",
      email: "reminder-#{SecureRandom.hex(4)}@example.com",
      username: "reminder#{SecureRandom.hex(4)}",
      email_verified: true
    )
    @membership = Membership.create!(
      group: @group,
      user: @invitee,
      inviter: @admin,
      created_at: 24.hours.ago.beginning_of_hour
    )
  end

  test "pending invitation reminder creates an eventless email notification" do
    assert_difference "ActionMailer::Base.deliveries.count", 1 do
      assert_difference -> { Notification.where(kind: "membership_resent").count }, 1 do
        assert_no_difference -> { TopicItem.where(kind: "announcement_resend").count } do
          InvitationReminderService.resend_pending
        end
      end
    end

    notification = Notification.find_by!(kind: "membership_resent", subject: @membership)
    assert_equal [ @invitee.id ], notification.notification_deliveries.where(channel: "email").pluck(:recipient_id)
  end

  test "accepted memberships are not reminded" do
    @membership.update!(accepted_at: Time.current)

    assert_no_difference "Notification.count" do
      InvitationReminderService.resend_pending
    end
  end

  test "retrying the reminder window preserves one notification and delivery" do
    InvitationReminderService.resend_pending

    assert_no_difference [ "Notification.count", "NotificationDelivery.count", "ActionMailer::Base.deliveries.count" ] do
      InvitationReminderService.resend_pending
    end
  end
end
