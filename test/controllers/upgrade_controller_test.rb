require 'test_helper'

if defined?(LoomioSubs)
class UpgradeControllerTest < ActionController::TestCase
  setup do
    @routes = LoomioSubs::Engine.routes

    hex = SecureRandom.hex(4)
    @user = User.create!(name: "upuser#{hex}", email: "upuser#{hex}@example.com",
                         username: "upuser#{hex}", email_verified: true)
    @group = Group.new(name: "upgroup#{hex}", group_privacy: 'secret')
    @group.creator = @user
    @group.save!
    @group.add_admin!(@user)

    ActionMailer::Base.deliveries.clear
  end

  # --- please_sign_in ---
  test "please_sign_in renders without auth" do
    get :please_sign_in
    assert_response :success
  end

  # --- index ---
  test "index renders please_sign_in when not logged in" do
    get :index
    assert_response :success  # renders PleaseSignIn view
  end

  test "index redirects to group upgrade when user has one group" do
    sign_in @user
    get :index
    assert_response :redirect
    assert_match %r{/upgrade/#{@group.id}}, response.location
  end

  test "index renders list when user has multiple adminable groups" do
    hex = SecureRandom.hex(4)
    group2 = Group.new(name: "upgroup2#{hex}", group_privacy: 'secret')
    group2.creator = @user
    group2.save!
    group2.add_admin!(@user)

    sign_in @user
    get :index
    assert_response :success
  end

  # --- show ---
  test "show renders please_sign_in when not logged in" do
    get :show, params: { group_id: @group.id }
    assert_response :success  # renders PleaseSignIn view
  end

  test "show renders upgrade page for group member" do
    sign_in @user
    get :show, params: { group_id: @group.id }
    assert_response :success
  end

  test "show creates trial subscription if none exists" do
    assert_nil @group.subscription
    sign_in @user
    get :show, params: { group_id: @group.id }
    assert_response :success
    @group.reload
    assert_not_nil @group.subscription
    assert_equal 'trial', @group.subscription.plan
  end

  test "show accepts pay and nonprofit params" do
    sign_in @user
    get :show, params: { group_id: @group.id, pay: 'monthly', nonprofit: 'true' }
    assert_response :success
  end

  # --- change_complete ---
  test "change_complete renders for admin" do
    sign_in @user
    get :change_complete, params: { group_id: @group.id }
    assert_response :success
  end

  test "change_complete requires sign in" do
    get :change_complete, params: { group_id: @group.id }
    assert_response :success  # renders PleaseSignIn
  end
end
end
