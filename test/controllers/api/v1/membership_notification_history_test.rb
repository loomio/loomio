require 'test_helper'

class Api::V1::MembershipNotificationHistoryTest < ActionController::TestCase
  tests Api::V1::MembershipsController

  setup do
    @membership = memberships(:member_normal_membership)
    @group = @membership.group
    @recipient = @membership.user
    @admin = users(:admin)
    @invitation = Notification.create!(kind: 'membership_created', subject: @group, actor: @admin,
      recipient_user_ids: [@recipient.id, users(:member_loud).id], recipient_message: 'Please join our forum',
      deliveries_generated_at: Time.current)
    @delivery = NotificationDelivery.create!(notification: @invitation, recipient: @recipient,
      channel: 'email', delivered_at: Time.current, email_subject: 'Join our forum')
    @delivery.events.create!(kind: 'bounced', source_key: 'report:1', occurred_at: Time.current, detail: '550 unknown user')
    sign_in @admin
  end

  test 'coordinators see repeated invitations and resends after acceptance without other recipients' do
    resend = Notification.create!(kind: 'membership_resent', subject: @membership, actor: @admin)
    # Another recipient, another group and unrelated activity must never be joined
    # into this membership's history, even when the same IDs appear elsewhere.
    Notification.create!(kind: 'membership_created', subject: @group, actor: @admin,
      recipient_user_ids: [users(:member_loud).id], recipient_message: 'Other recipient secret')
    Notification.create!(kind: 'membership_created', subject: groups(:alien_group), actor: @admin,
      recipient_user_ids: [@recipient.id], recipient_message: 'Other group secret')
    Notification.create!(kind: 'announcement_created', subject: @group, actor: @admin,
      recipient_user_ids: [@recipient.id], recipient_message: 'Unrelated message')
    get :notification_history, params: {id: @membership.id}

    assert_response :success
    rows = JSON.parse(response.body).fetch('history')
    assert_equal [resend.id, @invitation.id], rows.map { |row| row.fetch('id') }
    assert_equal 'Please join our forum', rows.last.fetch('message')
    assert_equal 'bounced', rows.last.fetch('email_status')
    assert_equal 'Join our forum', rows.last.fetch('email_subject')
    assert_equal '550 unknown user', rows.last.fetch('email_events').first.fetch('detail')
    refute_includes response.body, 'recipient_user_ids'
    refute_includes response.body, 'Other recipient secret'
    refute_includes response.body, 'Other group secret'
  end

  test 'history uses bounded limit and offset with a unique ordering tiebreak' do
    @invitation.update_columns(created_at: Time.current)
    resend = Notification.create!(kind: 'membership_resent', subject: @membership, actor: @admin,
      created_at: @invitation.created_at)
    get :notification_history, params: {id: @membership.id, limit: 1, offset: 0}
    assert_equal [resend.id], JSON.parse(response.body).fetch('history').map { |row| row.fetch('id') }
    get :notification_history, params: {id: @membership.id, limit: 1, offset: 1}
    assert_equal [@invitation.id], JSON.parse(response.body).fetch('history').map { |row| row.fetch('id') }
  end

  test 'ordinary members guests revoked members inactive users and unrelated administrators cannot read history' do
    %w[closed open].each do |privacy|
      @group.update!(group_privacy: privacy)
      %i[member_normal member_loud guest_normal non_guest_loud former_member_loud inactive_member_loud alien server_admin].each do |role|
        sign_in users(role)
        get :notification_history, params: {id: @membership.id}
        assert_includes [401, 403], response.status, role.to_s
        refute_includes response.body, 'Please join our forum', role.to_s
      end
    end
  end

  test 'a coordinator cannot read history for a discarded group' do
    @group.update!(discarded_at: Time.current)
    get :notification_history, params: {id: @membership.id}
    assert_response :forbidden
  end

  test 'an inviter without coordinator rights cannot read a membership history' do
    @membership.update!(inviter: users(:member_loud))
    sign_in users(:member_loud)
    get :notification_history, params: {id: @membership.id}
    assert_response :forbidden
  end

  test 'signed out users cannot read history even in a public group' do
    @group.update!(group_privacy: 'open')
    sign_out @admin
    get :notification_history, params: {id: @membership.id}
    assert_response :unauthorized
  end

  test 'missing historical email deliveries are not described as sent' do
    @delivery.destroy!
    get :notification_history, params: {id: @membership.id}
    assert_equal 'not_sent', JSON.parse(response.body).fetch('history').first.fetch('email_status')
  end
end
