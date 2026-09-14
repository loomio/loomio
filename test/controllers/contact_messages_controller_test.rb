require "test_helper"

class ContactMessagesControllerTest < ActionDispatch::IntegrationTest
  test "legacy contact form is not routed" do
    assert_raises(ActionController::RoutingError) do
      Rails.application.routes.recognize_path("/contact_messages/new", method: :get)
    end
  end
end
