require 'test_helper'
require Rails.root.join('db/migrate/20260824000000_rotate_exposed_user_api_keys')

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
    assert_operator response.parsed_body.dig('meta', 'total'), :>=, response.parsed_body.fetch('threads').length
  end

  test 'compact responses omit bulky related record types' do
    @request.headers['Authorization'] = "Bearer #{@user.api_key}"
    get :items, params: { id: @discussion.topic_id, compact: 1 }

    assert_response :success
    body = response.parsed_body
    assert_equal @discussion.topic.items.count, body.dig('meta', 'total')
    %w[topics groups parent_groups memberships reactions tags translations].each do |root|
      refute body.key?(root), "expected compact response to omit #{root}"
    end
  end

  test 'returns ordered thread items' do
    @request.headers['Authorization'] = "Bearer #{@user.api_key}"
    get :items, params: {id: @discussion.topic_id}

    assert_response 200
    sequence_ids = JSON.parse(response.body)['items'].map { |item| item['sequence_id'] }
    assert_equal sequence_ids.sort, sequence_ids
    assert_equal @discussion.topic.items.count, response.parsed_body.dig('meta', 'total')
  end

  test 'returns complete thread markdown' do
    @request.headers['Authorization'] = "Bearer #{@user.api_key}"
    get :markdown, params: {id: @discussion.topic_id}

    assert_response 200
    assert_includes JSON.parse(response.body)['markdown'], "# Discussion: #{@discussion.title}"
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

  test 'rejects an API key after the exposed keys are rotated' do
    api_key_before = @user.api_key

    RotateExposedUserApiKeys.new.migrate(:up)

    @request.headers['Authorization'] = "Bearer #{api_key_before}"
    get :index
    assert_response :forbidden

    @request.headers['Authorization'] = "Bearer #{@user.reload.api_key}"
    get :index
    assert_response :success
  end
end
