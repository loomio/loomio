require 'test_helper'

class Api::V1::ReceivedEmailsControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    @user = users(:user)
    @group = groups(:group)
    hex = SecureRandom.hex(4)
    @another_group = Group.create!(name: "unauth_group_#{hex}", handle: "unauthgrp#{hex}", group_privacy: 'secret')
    sign_in @admin
  end

  # ===== Index Tests =====

  test "index returns emails" do
    create_pending_email(
      group: @group,
      headers: {
        to: "#{@group.handle}@#{ENV['REPLY_HOSTNAME']}",
        from: "someone@gmail.com"
      },
      body_html: "<p>hello there</p>",
      body_text: "hello there"
    )

    get :index, params: { group_id: @group.id }

    json = JSON.parse(response.body)
    assert_response :success
    assert_equal 1, json['received_emails'].length
  end

  test 'the approval list reads envelope metadata without downloading message content' do
    email = create_pending_email(group: @group, headers: {from: 'Private Sender <private@example.test>', subject: 'Approval subject'}, body_text: 'Do not expose this body')
    ActiveStorage::Blob.stub(:find_signed, ->(*) { raise 'list must not inspect attachment content' }) do
      InboundEmailMessage.stub(:new, ->(*) { raise 'list must not parse the raw source' }) do
        get :index, params: {group_id: @group.id}
      end
    end
    assert_response :success
    row = response.parsed_body.fetch('received_emails').find { |record| record.fetch('id') == email.id }
    assert_equal 'Approval subject', row.fetch('subject')
    assert_equal 'private@example.test', row.fetch('sender_email')
    refute_includes response.body, 'Do not expose this body'
    refute row.key?('inbound_email_id')
  end

  test "index returns 403 when not an admin" do
    @group.memberships.find_by(user_id: @admin.id).update(admin: false)

    get :index, params: { group_id: @group.id }

    assert_response 403
  end

  test "index returns 403 for unauthorized group" do
    @group.memberships.find_by(user_id: @admin.id).update(admin: false)

    get :index, params: { group_id: @another_group.id }

    assert_response 403
  end

  # ===== Aliases Tests =====

  test "aliases returns email aliases" do
    MemberEmailAlias.create!(
      email: 'test@example.com',
      group_id: @group.id,
      user_id: @admin.id,
      author_id: @admin.id
    )

    get :aliases, params: { group_id: @group.id }

    json = JSON.parse(response.body)
    assert_response :success
    assert_equal 1, json['aliases'].length
  end

  test "aliases returns 403 for unauthorized group" do
    get :aliases, params: { group_id: @another_group.id }

    assert_response 403
  end

  # ===== Allow and Block Tests =====

  test "allow creates email alias" do
    received_email = create_pending_email(
      group: @group,
      headers: {
        to: "#{@group.handle}@#{ENV['REPLY_HOSTNAME']}",
        from: "someone@gmail.com",
        subject: "Test email subject"
      },
      body_html: "<p>hello there</p>",
      body_text: "hello there"
    )

    assert_difference 'MemberEmailAlias.count', 1 do
      post :allow, params: { id: received_email.id, user_id: @admin.id }
    end

    json = JSON.parse(response.body)
    assert_response :success
    assert_equal 1, json['received_emails'].length
    assert_equal @admin.id, MemberEmailAlias.last.user_id
  end

  test "allow succeeds when an alias for that sender already exists" do
    MemberEmailAlias.create!(
      email: 'someone@gmail.com',
      user_id: @user.id,
      group_id: @group.id,
      author_id: @user.id
    )
    received_email = create_pending_email(
      group: @group,
      headers: {
        to: "#{@group.handle}@#{ENV['REPLY_HOSTNAME']}",
        from: "someone@gmail.com",
        subject: "Test email subject"
      },
      body_html: "<p>hello there</p>",
      body_text: "hello there"
    )

    assert_difference 'MemberEmailAlias.count', 0 do
      post :allow, params: { id: received_email.id, user_id: @user.id }
    end
    assert_response :success
  end

  test "allow upgrades a previously blocked alias" do
    received_email = create_pending_email(
      group: @group,
      headers: {
        to: "#{@group.handle}@#{ENV['REPLY_HOSTNAME']}",
        from: "someone@gmail.com",
        subject: "Test email subject"
      },
      body_html: "<p>hello there</p>",
      body_text: "hello there"
    )
    MemberEmailAlias.create!(
      email: 'someone@gmail.com',
      user_id: nil,
      group_id: @group.id,
      author_id: @user.id
    )

    assert_difference 'MemberEmailAlias.count', 0 do
      post :allow, params: { id: received_email.id, user_id: @user.id }
    end
    assert_response :success
    assert_equal @user.id, MemberEmailAlias.find_by(email: 'someone@gmail.com', group_id: @group.id).user_id
  end

  test "allow returns 404 for wrong group" do
    another_received_email = create_pending_email(
      group: @another_group,
      headers: {
        to: "#{@another_group.handle}@#{ENV['REPLY_HOSTNAME']}",
        from: "someone@gmail.com"
      },
      body_html: "<p>hello there</p>",
      body_text: "hello there"
    )

    assert_difference 'MemberEmailAlias.count', 0 do
      post :allow, params: { id: another_received_email.id, user_id: @admin.id }
    end

    assert_response 404
  end

  test "allow returns 403 for trial group" do
    received_email = create_pending_email(
      group: @group,
      headers: {
        to: "#{@group.handle}@#{ENV['REPLY_HOSTNAME']}",
        from: "someone@gmail.com"
      },
      body_html: "<p>hello there</p>",
      body_text: "hello there"
    )

    Subscription.for(@group).update(plan: 'trial')

    assert_difference 'MemberEmailAlias.count', 0 do
      post :allow, params: { id: received_email.id, user_id: @admin.id }
    end

    assert_response 403
  end

  test "block creates email alias without user" do
    received_email = create_pending_email(
      group: @group,
      headers: {
        to: "#{@group.handle}@#{ENV['REPLY_HOSTNAME']}",
        from: "someone@gmail.com"
      },
      body_html: "<p>hello there</p>",
      body_text: "hello there"
    )
    notification = NotificationService.create!(
      kind: "unknown_sender",
      subject: received_email,
      actor: nil
    )

    assert_difference -> { MemberEmailAlias.count }, 1 do
      assert_difference -> { Notification.where(id: notification.id).count }, -1 do
        post :block, params: { id: received_email.id, user_id: @admin.id }
      end
    end

    json = JSON.parse(response.body)
    assert_response :success
    assert_equal 1, json['received_emails'].length
    assert_equal true, json['received_emails'].first.fetch('released')
    assert_nil MemberEmailAlias.last.user_id
  end

  test "block is idempotent when alias already exists" do
    received_email = create_pending_email(
      group: @group,
      headers: {
        to: "#{@group.handle}@#{ENV['REPLY_HOSTNAME']}",
        from: "someone@gmail.com"
      },
      body_html: "<p>hello there</p>",
      body_text: "hello there"
    )
    MemberEmailAlias.create!(
      email: 'someone@gmail.com',
      user_id: @user.id,
      group_id: @group.id,
      author_id: @user.id
    )

    assert_difference 'MemberEmailAlias.count', 0 do
      post :block, params: { id: received_email.id, user_id: @user.id }
    end
    assert_response :success
    assert_nil MemberEmailAlias.find_by(email: 'someone@gmail.com', group_id: @group.id).user_id
  end

  test "block returns 404 for wrong group" do
    another_received_email = create_pending_email(
      group: @another_group,
      headers: {
        to: "#{@another_group.handle}@#{ENV['REPLY_HOSTNAME']}",
        from: "someone@gmail.com"
      },
      body_html: "<p>hello there</p>",
      body_text: "hello there"
    )

    assert_difference 'MemberEmailAlias.count', 0 do
      post :block, params: { id: another_received_email.id, user_id: @admin.id }
    end

    assert_response 404
  end
  test 'approval payloads and mutations stay private to the group coordinators' do
    email = create_pending_email(group: @group, headers: {from: 'private-sender@example.test', subject: 'Private approval'})
    %i[member_normal guest_normal former_member_loud inactive_member_loud alien server_admin].each do |role|
      sign_in users(role)
      get :index, params: {group_id: @group.id}
      assert_includes [401, 403], response.status, role.to_s
      refute_includes response.body, 'private-sender@example.test'
      assert_no_difference ['MemberEmailAlias.count', 'Discussion.count'] do
        post :allow, params: {id: email.id, user_id: @admin.id}
        assert_includes [401, 404], response.status, role.to_s
        post :block, params: {id: email.id}
        assert_includes [401, 404], response.status, role.to_s
      end
      assert_equal @group.id, email.reload.group_id
    end
    sign_out
    get :index, params: {group_id: @group.id}
    assert_includes [401, 403], response.status
    post :allow, params: {id: email.id, user_id: @admin.id}
    assert_includes [401, 404], response.status
  end

  test 'approval cannot attribute a message to a user outside the group or an inactive account' do
    email = create_pending_email(group: @group, headers: {from: 'unknown@example.test'}, body_text: 'Keep pending')
    %i[alien inactive_member_loud].each do |role|
      assert_no_difference ['MemberEmailAlias.count', 'Discussion.count'] do
        post :allow, params: {id: email.id, user_id: users(role).id}
        assert_response :not_found
      end
      assert PendingEmail.exists?(email.id)
    end
  end

end
