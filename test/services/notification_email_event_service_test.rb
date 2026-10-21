require 'test_helper'

class NotificationEmailEventServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:member_normal)
    notification = Notification.create!(kind: 'membership_created', subject: groups(:group), actor: users(:admin))
    @delivery = NotificationDelivery.create!(notification: notification, recipient: @user, channel: 'email', email_address: @user.email)
  end

  test 'only permanent bounces and complaints suppress and their evidence survives clearance' do
    %w[Transient Undetermined].each do |type|
      record('bounced', type)
      refute @user.email_delivery_blocked?
    end
    record('delayed')
    refute @user.email_delivery_blocked?
    event = record('bounced', 'Permanent')
    suppression = EmailSuppression.for_address(@user.email).sole
    assert_equal event.id, suppression.notification_delivery_event_id
    assert_equal 'permanent_bounce', suppression.reason
    assert_equal event.occurred_at, suppression.occurred_at
    EmailSuppressionService.clear!(user: @user, actor: @user, method: 'sign_in')
    record('bounced', 'Permanent')
    refute @user.email_delivery_blocked?, 'a second reporting channel must not reinstate cleared evidence'
    record('complained')
    assert @user.email_delivery_blocked?
  end

  test 'late feedback for an old address does not block the new address' do
    old_address = @user.email
    @user.update!(email: 'new-address@example.com')
    record('complained')
    refute @user.email_delivery_blocked?
    assert EmailSuppression.for_address(old_address).active.exists?
  end

  test 'a failed suppression write rolls back the delivery event' do
    EmailSuppressionService.stub(:record!, ->(**) { raise 'storage failure' }) do
      assert_no_difference 'NotificationDeliveryEvent.count' do
        assert_raises(RuntimeError) { record('complained') }
      end
    end
  end

  private

  def record(kind, bounce_type = nil)
    NotificationEmailEventService.record!(delivery: @delivery, kind: kind, bounce_type: bounce_type,
      source_key: SecureRandom.uuid, occurred_at: Time.current)
  end
end
