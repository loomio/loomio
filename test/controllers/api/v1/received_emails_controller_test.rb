require 'test_helper'

class Api::V1::ReceivedEmailsControllerTest < ActionController::TestCase
  setup do
    @user = users(:admin)
    @group = groups(:group)
    hex = SecureRandom.hex(4)
    @another_group = Group.create!(name: "unauth_group_#{hex}", handle: "unauthgrp#{hex}", group_privacy: 'secret')
    sign_in @user
  end

  # ===== Index Tests =====

  test "index returns emails" do
    ReceivedEmail.create!(
      group_id: @group.id,
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

  test "index returns 403 when not an admin" do
    @group.memberships.find_by(user_id: @user.id).update(admin: false)

    get :index, params: { group_id: @group.id }

    assert_response 403
  end

  test "index returns 403 for unauthorized group" do
    @group.memberships.find_by(user_id: @user.id).update(admin: false)

    get :index, params: { group_id: @another_group.id }

    assert_response 403
  end

  # ===== Aliases Tests =====

  test "aliases returns email aliases" do
    MemberEmailAlias.create!(
      email: 'test@example.com',
      group_id: @group.id,
      user_id: @user.id,
      author_id: @user.id
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
    received_email = ReceivedEmail.create!(
      group_id: @group.id,
      headers: {
        to: "#{@group.handle}@#{ENV['REPLY_HOSTNAME']}",
        from: "someone@gmail.com",
        subject: "Test email subject"
      },
      body_html: "<p>hello there</p>",
      body_text: "hello there"
    )

    assert_difference 'MemberEmailAlias.count', 1 do
      post :allow, params: { id: received_email.id, user_id: @user.id }
    end

    json = JSON.parse(response.body)
    assert_response :success
    assert_equal 1, json['received_emails'].length
    assert_equal @user.id, MemberEmailAlias.last.user_id
  end

  test "allow returns 404 for wrong group" do
    another_received_email = ReceivedEmail.create!(
      group_id: @another_group.id,
      headers: {
        to: "#{@another_group.handle}@#{ENV['REPLY_HOSTNAME']}",
        from: "someone@gmail.com"
      },
      body_html: "<p>hello there</p>",
      body_text: "hello there"
    )

    assert_difference 'MemberEmailAlias.count', 0 do
      post :allow, params: { id: another_received_email.id, user_id: @user.id }
    end

    assert_response 404
  end

  test "allow returns 403 for trial group" do
    received_email = ReceivedEmail.create!(
      group_id: @group.id,
      headers: {
        to: "#{@group.handle}@#{ENV['REPLY_HOSTNAME']}",
        from: "someone@gmail.com"
      },
      body_html: "<p>hello there</p>",
      body_text: "hello there"
    )

    Subscription.for(@group).update(plan: 'trial')

    assert_difference 'MemberEmailAlias.count', 0 do
      post :allow, params: { id: received_email.id, user_id: @user.id }
    end

    assert_response 403
  end

  test "block creates email alias without user" do
    received_email = ReceivedEmail.create!(
      group_id: @group.id,
      headers: {
        to: "#{@group.handle}@#{ENV['REPLY_HOSTNAME']}",
        from: "someone@gmail.com"
      },
      body_html: "<p>hello there</p>",
      body_text: "hello there"
    )

    assert_difference 'MemberEmailAlias.count', 1 do
      post :block, params: { id: received_email.id, user_id: @user.id }
    end

    json = JSON.parse(response.body)
    assert_response :success
    assert_equal 1, json['received_emails'].length
    assert_nil MemberEmailAlias.last.user_id
  end

  test "block returns 404 for wrong group" do
    another_received_email = ReceivedEmail.create!(
      group_id: @another_group.id,
      headers: {
        to: "#{@another_group.handle}@#{ENV['REPLY_HOSTNAME']}",
        from: "someone@gmail.com"
      },
      body_html: "<p>hello there</p>",
      body_text: "hello there"
    )

    assert_difference 'MemberEmailAlias.count', 0 do
      post :block, params: { id: another_received_email.id, user_id: @user.id }
    end

    assert_response 404
  end
end
