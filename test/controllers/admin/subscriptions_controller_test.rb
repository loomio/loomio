require "test_helper"

if defined?(LoomioSubs)
class Admin::SubscriptionsControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    @subscription = Subscription.create!(
      owner: @admin,
      plan: "trial",
      state: "active",
      payment_method: "manual",
      chargify_subscription_id: 12345
    )
  end

  test "index redirects unauthenticated and non-admin users" do
    get :index
    assert_redirected_to dashboard_path

    sign_in users(:user)
    get :index
    assert_redirected_to dashboard_path
  end

  test "admin can filter subscriptions from the top of the index" do
    Subscription.create!(owner: users(:user), plan: "free", state: "canceled")
    sign_in @admin

    get :index, params: { chargify_id: @subscription.chargify_subscription_id, page: 1, commit: "Search" }

    assert_response :success
    assert_includes response.body, "12345"
    refute_includes response.body, "canceled"
    assert_operator response.body.index("Chargify subscription ID"), :<, response.body.index("admin-table")
  end

  test "admin can show edit and update a subscription" do
    sign_in @admin

    get :show, params: { id: @subscription.id }
    assert_response :success
    assert_includes response.body, "Refresh from Chargify"
    assert_includes response.body, 'data-confirm="Refresh this subscription from Chargify?"'

    get :edit, params: { id: @subscription.id }
    assert_response :success
    document = Nokogiri::HTML(response.body)
    assert_equal SubscriptionService::PLANS.keys.map(&:to_s), select_values(document, "subscription_plan")
    assert_equal Subscription::PAYMENT_METHODS, select_values(document, "subscription_payment_method")
    assert_equal Subscription::STATES, select_values(document, "subscription_state")

    put :update, params: { id: @subscription.id, subscription: { plan: "community", max_members: 200 } }
    assert_redirected_to admin_subscription_path(@subscription)
    assert_equal "community", @subscription.reload.plan
    assert_equal 200, @subscription.max_members
  end

  test "subscription update rejects unpermitted attributes" do
    sign_in @admin

    assert_raises(ActionController::UnpermittedParameters) do
      put :update, params: { id: @subscription.id, subscription: { lead_status: "not permitted" } }
    end

    refute_equal "not permitted", @subscription.reload.lead_status
  end

  test "subscription update shows validation errors" do
    sign_in @admin
    original_owner_id = @subscription.owner_id

    put :update, params: { id: @subscription.id, subscription: { owner_id: User.maximum(:id) + 1 } }

    assert_response :unprocessable_entity
    assert_equal original_owner_id, @subscription.reload.owner_id
    assert_includes response.body, "Subscription could not be updated"
    assert_includes response.body, "Owner must exist"
  end

  test "admin can refresh a Chargify subscription" do
    sign_in @admin
    payload = { "subscription" => { "state" => "active" } }
    updated = nil

    service = Object.new
    service.define_singleton_method(:chargify_get) { |_id| payload }
    service.define_singleton_method(:update) { |subscription:, params:| updated = [subscription, params] }

    @controller.stub(:subscription_service, service) do
      post :refresh, params: { id: @subscription.id }
    end

    assert_equal [@subscription, payload], updated
    assert_redirected_to admin_subscription_path(@subscription)
  end

  test "non-admin cannot update or refresh a subscription" do
    sign_in users(:user)

    put :update, params: { id: @subscription.id, subscription: { plan: "free" } }
    assert_redirected_to dashboard_path
    assert_equal "trial", @subscription.reload.plan

    called = false
    service = Object.new
    service.define_singleton_method(:chargify_get) { |_id| called = true }

    @controller.stub(:subscription_service, service) do
      post :refresh, params: { id: @subscription.id }
    end
    refute called
    assert_redirected_to dashboard_path
  end

  private

  def select_values(document, id)
    document.css("select##{id} option").map { |option| option["value"] }
  end
end
else
class Admin::SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  test "subscription admin routes are unavailable without loomio_subs" do
    assert_raises(ActionController::RoutingError) do
      Rails.application.routes.recognize_path("/admin/subscriptions", method: :get)
    end
  end
end
end
