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

  test 'pages thread items in sequence order while preserving the complete total' do
    @request.headers['Authorization'] = "Bearer #{@user.api_key}"
    2.times do |index|
      CommentService.create(comment: Comment.new(parent: @discussion, body: "Page comment #{index}"), actor: @user)
    end
    expected_ids = @discussion.topic.items.order(:sequence_id, :id).pluck(:id)
    actual_ids = expected_ids.each_index.flat_map do |offset|
      get :items, params: { id: @discussion.topic_id, limit: 1, offset: offset, compact: 1 }

      assert_response :success
      assert_equal expected_ids.length, response.parsed_body.dig('meta', 'total')
      response.parsed_body.fetch('items').pluck('id')
    end
    assert_equal expected_ids, actual_ids

    get :items, params: { id: @discussion.topic_id, limit: 1, offset: expected_ids.length }

    assert_response :success
    assert_empty response.parsed_body.fetch('items')
    assert_equal expected_ids.length, response.parsed_body.dig('meta', 'total')
  end

  test 'item pages retain group and direct topic access boundaries' do
    allowed = {
      discussion_topic: %i[admin member guest_normal guest_admin_normal former_member_guest],
      direct_topic: %i[guest_normal guest_admin_normal]
    }
    denied = {
      discussion_topic: %i[alien former_member_loud former_guest_loud non_guest_loud server_admin],
      direct_topic: %i[admin member alien former_guest_loud non_guest_loud server_admin]
    }

    [allowed, denied].each do |matrix|
      matrix.each do |topic_name, roles|
        roles.each do |role|
          user = users(role)
          user.update_columns(api_key: "item-page-key-#{SecureRandom.hex(8)}")
          @request.headers['Authorization'] = "Bearer #{user.api_key}"
          get :items, params: { id: topics(topic_name).id, limit: 1, offset: 0 }

          if matrix.equal?(allowed)
            assert_response :success
            assert_equal topics(topic_name).items.count, response.parsed_body.dig('meta', 'total')
          else
            assert_response :not_found
            refute response.parsed_body.key?('items'), "#{topic_name}: #{role}"
            refute response.parsed_body.key?('meta'), "#{topic_name}: #{role}"
          end
        end
      end
    end
  end

  test 'public item pages remain readable without group membership but require an active API user' do
    @request.headers['Authorization'] = "Bearer #{@user.api_key}"
    topic = topics(:public_discussion_topic)
    expected_ids = topic.items.order(:sequence_id, :id).pluck(:id)

    get :items, params: { id: topic.id, limit: 1, offset: 1 }

    assert_response :success
    assert_equal expected_ids.drop(1).first(1), response.parsed_body.fetch('items').pluck('id')
    assert_equal expected_ids.length, response.parsed_body.dig('meta', 'total')

    [nil, "Bearer #{users(:inactive_guest_loud).api_key}"].each do |authorization|
      @request.headers['Authorization'] = authorization
      get :items, params: { id: topic.id, limit: 1, offset: 0 }

      assert_response :forbidden
      refute response.parsed_body.key?('items')
    end
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
