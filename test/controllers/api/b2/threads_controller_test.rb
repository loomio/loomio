require 'test_helper'

class Api::B2::ThreadsControllerTest < ActionController::TestCase
  setup do
    @user = users(:user)
    @user.update_columns(api_key: "apikey#{SecureRandom.hex(8)}")
    @discussion = discussions(:discussion)
  end

  test 'lists threads visible to the user' do
    @request.headers['Authorization'] = "Bearer #{@user.api_key}"
    get :index

    assert_response 200
    thread = JSON.parse(response.body)['threads'].find { |item| item['id'] == @discussion.topic_id }
    assert_equal @discussion.topic_id, thread['id']
  end

  test 'returns ordered thread items' do
    @request.headers['Authorization'] = "Bearer #{@user.api_key}"
    get :items, params: {id: @discussion.topic_id}

    assert_response 200
    sequence_ids = JSON.parse(response.body)['items'].map { |item| item['sequence_id'] }
    assert_equal sequence_ids.sort, sequence_ids
  end

  test 'returns complete thread markdown' do
    @request.headers['Authorization'] = "Bearer #{@user.api_key}"
    get :markdown, params: {id: @discussion.topic_id}

    assert_response 200
    assert_includes JSON.parse(response.body)['markdown'], "# #{@discussion.title}"
  end

  test 'does not expose an inaccessible thread' do
    outsider = User.create!(name: 'outsider', email: "outsider#{SecureRandom.hex(4)}@example.com", username: "outsider#{SecureRandom.hex(4)}", email_verified: true)
    outsider.update_columns(api_key: "apikey#{SecureRandom.hex(8)}")

    @request.headers['Authorization'] = "Bearer #{outsider.api_key}"
    get :show, params: {id: @discussion.topic_id}

    assert_response 404
  end

  test 'rejects API keys in the query string' do
    get :index, params: { api_key: @user.api_key }

    assert_response :forbidden
  end
end
