require 'test_helper'

class EmailSuppressionServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:member_normal)
    @admin = users(:admin)
  end

  test 'blocks use normalized addresses and apply across email changes and account replacement' do
    original = @user.email
    record = EmailSuppressionService.record!(email: "  #{original.upcase}  ", reason: 'complaint', source_key: 'test:complaint')
    assert @user.email_delivery_blocked?
    refute User.email_deliverable.exists?(@user.id)
    assert ApplicationMailer.new.send(:rejected_address?, "A person <#{original.upcase}>")
    @user.update!(email: 'replacement@example.com')
    refute @user.email_delivery_blocked?
    assert User.email_deliverable.exists?(@user.id)
    replacement = User.create!(name: 'Replacement', email: original, email_verified: true)
    assert replacement.email_delivery_blocked?
    assert_nil record.notification_delivery_event_id
    refute record.attributes.values.include?(original)
    refute LoggedOutUser.new.email_delivery_blocked?
  end

  test 'clearance retains evidence and cannot be undone by replaying it' do
    record = EmailSuppressionService.record!(email: @user.email, reason: 'complaint', source_key: 'test:complaint')
    EmailSuppressionService.clear!(user: @user, actor: @admin, method: 'administrator')
    record.reload
    assert record.cleared_at
    assert_equal @admin.id, record.cleared_by_id
    assert_equal 'administrator', record.clear_method
    refute @user.email_delivery_blocked?
    assert_equal record.id, EmailSuppressionService.record!(email: @user.email, reason: 'complaint', source_key: 'test:complaint').id
    refute @user.email_delivery_blocked?
    EmailSuppressionService.record!(email: @user.email, reason: 'permanent_bounce', source_key: 'test:new-bounce')
    assert @user.email_delivery_blocked?
  end

  test 'clearing the current address leaves the previous address blocked' do
    old_email = @user.email
    record = EmailSuppressionService.record!(email: old_email, reason: 'complaint', source_key: 'test:old')
    @user.update!(email: 'new-address@example.com')
    EmailSuppressionService.record!(email: @user.email, reason: 'complaint', source_key: 'test:new')
    EmailSuppressionService.clear!(user: @user, actor: @user, method: 'sign_in')
    refute @user.email_delivery_blocked?
    assert_nil record.reload.cleared_at
  end
end
