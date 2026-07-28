require "test_helper"

class Api::V1::LinkPreviewsControllerTest < ActionController::TestCase
  test "create does not inspect a topic the user cannot view" do
    sign_in users(:user)

    post :create, params: {
      topic_id: discussions(:alien_discussion).topic.id,
      urls: ["https://example.com/private-link"]
    }

    assert_response :forbidden
  end
end
