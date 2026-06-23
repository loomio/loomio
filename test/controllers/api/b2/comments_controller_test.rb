require 'test_helper'

class Api::B2::CommentsControllerTest < ActionController::TestCase
  setup do
    @user = users(:user)
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
    comment = json['comments'][0]
    assert comment['id'].present?
    assert_equal @discussion.topic_id, comment['topic_id']
    assert_equal 'This is a test comment', comment['body']
  end

  test "update happy case" do
    @discussion.group.update!(members_can_edit_comments: true)
    comment = create_comment!

    patch :update, params: {
      id: comment.id,
      body: 'Updated via API',
      body_format: 'md',
      api_key: @user.api_key
    }

    assert_response 200
    assert_equal 'Updated via API', comment.reload.body
    assert_equal 'Updated via API', json['comments'][0]['body']
    assert comment.edited_at.present?
  end

  test "update missing permission" do
    @discussion.group.update!(members_can_edit_comments: false)
    comment = create_comment!

    patch :update, params: {
      id: comment.id,
      body: 'Blocked update',
      api_key: @user.api_key
    }

    assert_response 403
    refute_equal 'Blocked update', comment.reload.body
  end

  test "destroy soft deletes comment" do
    comment = create_comment!

    delete :destroy, params: {
      id: comment.id,
      api_key: @user.api_key
    }

    assert_response 200
    comment.reload
    assert comment.discarded_at.present?
    assert_equal @user.id, comment.discarded_by
    assert_nil json['comments'][0]['body']
    assert json['comments'][0]['discarded_at'].present?
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

  private

  def create_comment!
    post :create, params: {
      body: 'Original comment',
      body_format: 'md',
      discussion_id: @discussion.id,
      api_key: @user.api_key
    }
    assert_response 200
    Comment.find(json['comments'][0]['id'])
  end

  def json
    JSON.parse(response.body)
  end
end
