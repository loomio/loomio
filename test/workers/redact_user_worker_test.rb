require 'test_helper'

class RedactUserWorkerTest < ActiveSupport::TestCase
  test 'redaction erases email snapshots and diagnostics without losing nonpersonal history' do
    user = users(:member_normal)
    notification = Notification.create!(kind: 'membership_created', subject: groups(:group), actor: users(:admin))
    delivery = NotificationDelivery.create!(notification: notification, recipient: user, channel: 'email',
      email_address: user.email, email_subject: 'Invitation for member', email_message_id: 'message@loomio.test',
      provider_message_id: 'ses-private-id')
    event = delivery.events.create!(kind: 'bounced', source_key: 'feedback:one', occurred_at: Time.current,
      detail: "550 Unknown mailbox #{user.email}")

    suppression = EmailSuppressionService.record!(email: user.email, reason: 'permanent_bounce',
      source_key: 'test:redacted', event: event, occurred_at: event.occurred_at)
    address_digest = EmailSuppression.address_digest(user.email)
    RedactUserWorker.perform_now(user.id, user.id, false)
    delivery.reload
    assert_nil delivery.email_address
    assert_nil delivery.email_subject
    assert_nil delivery.email_message_id
    assert_nil delivery.provider_message_id
    assert_nil event.reload.detail
    assert_equal 'bounced', event.kind
    assert_equal address_digest, suppression.reload.email_sha256
    assert_equal event.id, suppression.notification_delivery_event_id
    assert_no_difference ['NotificationDeliveryEvent.count', 'EmailSuppression.count'] do
      NotificationEmailEventService.record!(delivery: delivery, kind: 'complained', source_key: 'late-feedback',
        occurred_at: Time.current, detail: 'Personal information from a late report')
    end
  end

  test "permanently removes passkeys and their account user handle" do
    user = User.create!(name: "Redacted User", email: "redacted-passkeys@example.com", email_verified: true)
    PasskeyService.ensure_webauthn_id!(user)
    user.passkey_credentials.create!(
      external_id: "redacted-passkey",
      public_key: "redacted-public-key",
      user_handle: user.webauthn_id,
      sign_count: 0,
      name: "Redacted passkey"
    )

    assert_difference "PasskeyCredential.count", -1 do
      RedactUserWorker.perform_now(user.id, user.id, false)
    end

    assert_nil user.reload.webauthn_id
  end
end
