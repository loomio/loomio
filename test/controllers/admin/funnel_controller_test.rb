require 'test_helper'

class Admin::FunnelControllerTest < ActionController::TestCase
  setup do
    @routes = LoomioSubs::Engine.routes

    hex = SecureRandom.hex(4)
    @admin = User.create!(name: "fnadmin#{hex}", email: "fnadmin#{hex}@example.com",
                          username: "fnadmin#{hex}", email_verified: true, is_admin: true)
    @user = User.create!(name: "fnuser#{hex}", email: "fnuser#{hex}@example.com",
                         username: "fnuser#{hex}", email_verified: true)

    @group = Group.new(name: "fngroup#{hex}", group_privacy: 'secret')
    @group.creator = @admin
    @group.save!

    @subscription = Subscription.create!(plan: 'trial', state: 'active')
    @group.update!(subscription: @subscription)

    ActionMailer::Base.deliveries.clear
  end

  # --- show ---
  test "show redirects non-admin to dashboard" do
    sign_in @user
    get :show
    assert_response :redirect
  end

  test "show redirects unauthenticated to dashboard" do
    get :show
    assert_response :redirect
  end

  test "show renders for admin" do
    sign_in @admin
    get :show
    assert_response :success
  end

  test "show accepts filter params" do
    sign_in @admin
    get :show, params: { start_on: 12.weeks.ago.to_date.to_s, end_on: Date.today.to_s,
                         subscription_plan: "trial", subscription_lead_status: nil }
    assert_response :success
  end

  # --- update ---
  test "update redirects non-admin" do
    sign_in @user
    put :update, params: { id: @subscription.id, lead_status: "customer" }
    assert_response :redirect
    assert_nil @subscription.reload.lead_status
  end

  test "update sets lead_status for admin" do
    sign_in @admin
    put :update, params: { id: @subscription.id, lead_status: "customer" }
    assert_response :redirect
    assert_equal "customer", @subscription.reload.lead_status
  end

  test "update can set lead_status to ignore" do
    sign_in @admin
    put :update, params: { id: @subscription.id, lead_status: "ignore" }
    assert_equal "ignore", @subscription.reload.lead_status
  end
end
