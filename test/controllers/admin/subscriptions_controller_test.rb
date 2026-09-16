require "test_helper"

class Admin::SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  test "subscription admin routes are unavailable without loomio_subs" do
    assert_raises(ActionController::RoutingError) do
      Rails.application.routes.recognize_path("/admin/subscriptions", method: :get)
    end
  end
end
