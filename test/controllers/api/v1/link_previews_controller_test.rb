require "test_helper"

class Api::V1::LinkPreviewsControllerTest < ActionController::TestCase
  test "create shares the 100 per hour limit across users" do
    urls = ["https://example.com/page"]
    fetches = 0
    SafeHttpService.stub(:fetch_urls, ->(_urls) { fetches += 1; [] }) do
      %i[member_normal member_loud guest_normal guest_loud guest_admin_normal].each do |role|
        sign_in users(role)
        20.times do
          post :create, params: {urls: urls}
          assert_response :success
        end
      end

      sign_in users(:admin)
      post :create, params: {urls: urls}
      assert_response :too_many_requests
    end
    assert_equal 100, fetches
  end

  test "create keeps the per user limit below the shared limit" do
    sign_in users(:user)
    SafeHttpService.stub(:fetch_urls, []) do
      20.times do
        post :create, params: {urls: ["https://example.com/page"]}
        assert_response :success
      end
    end

    SafeHttpService.stub(:fetch_urls, ->(_) { flunk "throttled requests must not fetch URLs" }) do
      post :create, params: {urls: ["https://example.com/page"]}
      assert_response :too_many_requests
    end
  end

  test "signed out requests do not fetch URLs" do
    SafeHttpService.stub(:fetch_urls, ->(_) { flunk "signed out requests must not fetch URLs" }) do
      post :create, params: {urls: ["https://example.com/page"]}
      assert_response :unauthorized
    end
  end

  test "create does not inspect a topic the user cannot view" do
    sign_in users(:user)

    post :create, params: {
      topic_id: discussions(:alien_discussion).topic.id,
      urls: ["https://example.com/private-link"]
    }

    assert_response :forbidden
  end

  test "preview requests preserve group and direct topic access boundaries" do
    %i[discussion_topic direct_topic].each do |fixture|
      topic = topics(fixture)
      {
        member_normal: fixture == :discussion_topic,
        guest_normal: true,
        alien_loud: false,
        non_guest_loud: false,
        former_member_loud: false,
        former_guest_loud: false,
        server_admin: false
      }.each do |role, allowed|
        sign_in users(role)
        SafeHttpService.stub(:fetch_urls, ->(urls) {
          assert allowed, "#{fixture}: #{role} must not fetch URLs"
          assert_equal ["https://example.com/page"], urls
          []
        }) do
          post :create, params: {topic_id: topic.id, urls: ["https://example.com/page"]}
          assert_response allowed ? :success : :forbidden
        end
      end
    end
  end
end
