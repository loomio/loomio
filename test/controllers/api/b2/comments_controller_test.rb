require 'test_helper'

class Api::B2::CommentsControllerTest < ActionController::TestCase
  setup do
    @user = users(:admin)
    @user.update_columns(api_key: "apikey#{SecureRandom.hex(8)}")
    @discussion = discussions(:discussion)
  end

  test "create happy case" do
    post :create, params: {
      body: 'This is a test comment',
      body_format: 'md',
      discussion_id: @discussion.id,
      api_key: @user.api_key
    }
    assert_response 200
    json = JSON.parse(response.body)
    comment = json['comments'][0]
    assert comment['id'].present?
    assert_equal @discussion.id, comment['discussion_id']
    assert_equal 'This is a test comment', comment['body']
  end

  test "create missing discussion_id" do
    post :create, params: {
      body: 'Test comment',
      api_key: @user.api_key
    }
    assert_response 403
  end

  test "create blank body" do
    post :create, params: {
      body: '',
      discussion_id: @discussion.id,
      api_key: @user.api_key
    }
    assert_response 422
  end

  test "create missing permission" do
    hex = SecureRandom.hex(4)
    outsider = User.create!(name: "outsider#{hex}", email: "outsider#{hex}@example.com", username: "outsider#{hex}", email_verified: true)
    outsider.update_columns(api_key: "apikey#{SecureRandom.hex(8)}")
    post :create, params: {
      body: 'Test comment',
      discussion_id: @discussion.id,
      api_key: outsider.api_key
    }
    assert_response 403
  end

  test "create incorrect key" do
    post :create, params: {
      body: 'Test comment',
      discussion_id: @discussion.id,
      api_key: 'wrongkey123'
    }
    assert_response 403
  end

  test "create blank key" do
    post :create, params: {
      body: 'Test comment',
      discussion_id: @discussion.id
    }
    assert_includes [400, 403], response.status, "Expected 400 or 403 but got #{response.status}"
  end
end
