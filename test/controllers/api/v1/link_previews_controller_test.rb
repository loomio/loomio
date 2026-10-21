require "test_helper"

class Api::V1::LinkPreviewsControllerTest < ActionController::TestCase
  test "create returns fetched previews without a topic" do
    actor = users(:member_normal)
    urls = ["https://example.com/new-link"]
    previews = [{ "url" => urls.first, "title" => "New link" }]
    sign_in actor

    SafeHttpService.stub(:fetch_urls, ->(requested) { assert_equal urls, requested; previews }) do
      post :create, params: { urls: urls }
    end

    assert_response :success
    assert_equal previews, response.parsed_body.fetch('previews')
  end

  test "create omits previews already stored on a readable topic" do
    topic = topics(:discussion_topic)
    existing_url = 'https://example.com/existing-link'
    new_url = 'https://example.com/new-link'
    topic.topicable.update!(link_previews: [{ url: existing_url, title: 'Existing link' }])
    assert_includes TopicService.extract_link_preview_urls(topic), existing_url
    sign_in users(:member_normal)
    previews = [{ 'url' => new_url, 'title' => 'New link' }]

    SafeHttpService.stub(:fetch_urls, ->(requested) { assert_equal [new_url], requested; previews }) do
      post :create, params: { topic_id: topic.id, urls: [existing_url, new_url] }
    end

    assert_response :success
    assert_equal previews, response.parsed_body.fetch('previews')
  end

  test "create stops fetching when the signed in account exhausts its preview budget" do
    actor = users(:member_normal)
    sign_in actor
    Rails.cache.delete(ThrottleService.cache_key(key: 'LinkPreviews', id: actor.id))
    SafeHttpService.stub(:fetch_urls, ->(_) { [] }) do
      20.times do
        post :create, params: { urls: ['https://example.com/link'] }
        assert_response :success
      end
    end
    SafeHttpService.stub(:fetch_urls, ->(_) { flunk 'rate limited requests must not fetch URLs' }) do
      post :create, params: { urls: ['https://example.com/link'] }
    end

    assert_response :too_many_requests
    assert_equal 'Rate limit exceeded', response.parsed_body.fetch('error')
  ensure
    Rails.cache.delete(ThrottleService.cache_key(key: 'LinkPreviews', id: actor.id)) if actor
  end

  test "create does not inspect a topic the user cannot view" do
    sign_in users(:user)

    post :create, params: {
      topic_id: discussions(:alien_discussion).topic.id,
      urls: ["https://example.com/private-link"]
    }

    assert_response :forbidden
  end
end
