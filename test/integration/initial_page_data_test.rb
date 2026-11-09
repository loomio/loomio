require 'test_helper'

class InitialPageDataTest < ActionDispatch::IntegrationTest
  setup do
    @saved_env = %w[FEATURES_DISABLE_EMAIL_LOGIN FEATURES_EXPLORE_PUBLIC_GROUPS TURNSTILE_SECRET_KEY TERMS_URL].to_h { |key| [key, ENV.delete(key)] }
  end

  teardown do
    @saved_env.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
  end

  test 'dashboard and inbox embed exactly the authorized API responses for members guests and revoked users' do
    %i[member_normal guest_normal guest_admin_normal former_member_loud former_guest_loud server_admin].each do |role|
      authenticate(users(role))
      ['/dashboard', '/inbox'].each do |path|
        get path, headers: browser_headers
        assert_response :success
        assert_equal 'no-store', response.headers['Cache-Control']
        data = initial_data
        assert_equal users(role).id, data['boot']['current_user_id']
        expected_paths = path == '/dashboard' ? %w[/api/v1/topics /api/v1/polls] : ['/api/v1/topics']
        assert_equal expected_paths, data['requests'].pluck('path')

        data['requests'].each do |request|
          get request['path'], params: request['params'], as: :json
          assert_response :success
          assert_equal response.parsed_body, request['records'], "#{role}: #{path} #{request['path']} #{request['params']}"
        end

        if %i[former_member_loud former_guest_loud server_admin].include?(role)
          topic_ids = data['requests'].flat_map { |request| request['records'].fetch('topics', []).pluck('id') }
          refute_includes topic_ids, topics(:discussion_topic).id
          refute_includes topic_ids, topics(:direct_topic).id
        end
      end
      delete '/api/v1/sessions', as: :json
    end
  end

  test 'signed out list pages contain only boot configuration and no personal records' do
    ['/dashboard', '/inbox'].each do |path|
      get path, headers: browser_headers
      assert_response :success
      assert_nil initial_data['boot']['current_user_id']
      assert_empty initial_data['requests']
    end
  end

  test 'ordinary discussion opens preload the beginning even when the reader has unread replies' do
    user = users(:member_normal)
    discussion = discussions(:discussion)
    CommentService.create(comment: Comment.new(parent: discussion, body: 'Unread reply'), actor: users(:admin))
    topic = discussion.topic.reload
    TopicReader.for(user: user, topic: topic).update!(read_ranges: [[0, 0]], last_read_at: 1.hour.ago)
    authenticate(user)

    get "/d/#{discussion.key}", headers: browser_headers
    assert_response :success
    request = initial_data['requests'].find { |row| row['params'].key?('discussion_key') }
    assert_equal 'sequence_id', request['params']['order_by']
    assert_includes request['records']['topic_items'].pluck('sequence_id'), 0
    get request['path'], params: request['params'], as: :json
    assert_equal normalize_times(response.parsed_body.except('meta')), normalize_times(request['records'])
  end

  test 'ordinary app pages include boot configuration without preloading secondary records' do
    ENV['FEATURES_EXPLORE_PUBLIC_GROUPS'] = '1'
    [nil, users(:member_normal)].each do |user|
      authenticate(user) if user
      %w[/bookmarks /tasks /notifications /profile /g/new /contact /explore].each do |path|
        get path, headers: browser_headers
        assert_response :success, path
        if user
          assert_equal user.id, initial_data['boot']['current_user_id']
        else
          assert_nil initial_data['boot']['current_user_id']
        end
        assert_empty initial_data['requests'], path
        assert_equal 'no-store', response.headers['Cache-Control']
      end
    end
  end

  test 'group keys and handles bootstrap exactly the visible group and discussion list' do
    group = groups(:group)
    group.update!(is_visible_to_public: true, discussion_privacy_options: 'public_or_private')
    public_discussion = DiscussionService.create(params: {group_id: group.id, title: 'Public initial thread', private: false}, actor: users(:admin))
    assert public_discussion.persisted?, public_discussion.errors.full_messages.join(', ')
    %i[member_normal guest_normal guest_admin_normal former_member_loud former_guest_loud alien server_admin].each do |role|
      authenticate(users(role))
      ["/g/#{group.key}/group-name", "/#{group.handle}"].each do |path|
        get path, headers: browser_headers
        assert_response :success
        assert_equal 'no-store', response.headers['Cache-Control']
        data = initial_data
        assert_equal 2, data['requests'].size
        assert_equal '/api/v1/topics', data['requests'].last['path']
        rows = data['requests'].last['records']['topics']
        assert_includes rows.pluck('id'), public_discussion.topic_id
        if %i[former_member_loud former_guest_loud alien server_admin].include?(role)
          refute_includes rows.pluck('id'), topics(:discussion_topic).id
        else
          assert_includes rows.pluck('id'), topics(:discussion_topic).id
        end
        data['requests'].each do |request|
          get request['path'], params: request['params'], as: :json
          assert_response :success
          assert_equal normalize_times(response.parsed_body), normalize_times(request['records']), role.to_s
        end
      end
      delete '/api/v1/sessions', as: :json
    end

    get "/g/#{group.key}", headers: browser_headers
    assert_response :success
    assert_nil initial_data['boot']['current_user_id']
    assert_equal [public_discussion.topic_id], page_topics.pluck('id')
  end

  test 'opening a group redeems the viewers pending membership before embedding its records' do
    user = users(:member_normal)
    authenticate(user)
    membership = memberships(:member_normal_membership)
    membership.update!(accepted_at: nil)

    get "/g/#{groups(:group).key}", headers: browser_headers
    assert_response :success
    assert membership.reload.accepted_at
    request = initial_data['requests'].first
    get request['path'], params: request['params'], as: :json
    assert_equal normalize_times(response.parsed_body), normalize_times(request['records'])
  end

  test 'group bootstrap follows filters and bounded pagination without trusting unrelated API parameters' do
    user = users(:admin)
    authenticate(user)
    group = groups(:group)
    27.times do |i|
      discussion = DiscussionService.create(params: {group_id: group.id, title: "Page thread #{i}"}, actor: user)
      discussion.topic.update!(tags: ['Planning'], locked_at: i == 0 ? Time.current : nil)
    end
    [{}, {page: 2}, {t: 'locked'}, {t: 'all'}, {t: 'unread'}, {tag: 'Planning'}].each do |query|
      get "/g/#{group.key}", params: query.merge(subgroups: 'all', topicable_type: 'Poll', per: 10000), headers: browser_headers
      assert_response :success
      request = initial_data['requests'].find { |row| row['path'] == '/api/v1/topics' }
      assert_equal group.id, request['params']['group_id']
      assert_equal 25, request['params']['per']
      assert_operator request['records']['topics'].size, :<=, 25
      get request['path'], params: request['params'], as: :json
      assert_equal normalize_times(response.parsed_body), normalize_times(request['records'])
    end

    get "/g/#{group.key}/polls", headers: browser_headers
    assert_equal ["/api/v1/groups/#{group.key}"], initial_data['requests'].pluck('path')

    get "/g/#{group.key}", params: {group_id: groups(:alien_group).id}, headers: browser_headers
    assert_response :forbidden
    assert_select '#initial-data', count: 0
  end

  test 'inbox excludes read and dismissed threads while dashboard retains them' do
    user = users(:member_normal)
    authenticate(user)
    reader = TopicReader.for(user: user, topic: topics(:discussion_topic))
    reader.update!(last_read_at: Time.current, dismissed_at: Time.current)

    get '/inbox', headers: browser_headers
    assert_empty page_topics.select { |topic| topic['id'] == topics(:discussion_topic).id }
    get '/dashboard', headers: browser_headers
    assert_includes page_topics.pluck('id'), topics(:discussion_topic).id
  end

  test 'poll links embed the API window for standalone and embedded polls including closed polls' do
    user = users(:admin)
    authenticate(user)
    [nil, topics(:discussion_topic).id].each do |topic_id|
      poll = PollService.create(params: {
        title: 'Initial poll window', poll_type: 'proposal', topic_id: topic_id,
        poll_option_names: %w[Agree Disagree], closing_at: 3.days.from_now
      }, actor: user)
      [false, true].each do |closed|
        PollService.close(poll: poll, actor: user) if closed
        get "/p/#{poll.key}", headers: {'User-Agent' => 'Mozilla/5.0 Chrome/130.0.0.0 Safari/537.36'}
        assert_response :success
        request = initial_data['requests'].find { |row| row['params'].key?('poll_key') }
        records = request['records']
        assert_includes records['polls'].pluck('id'), poll.id
        assert_includes records['topics'].pluck('id'), poll.topic_id
        get request['path'], params: request['params'], as: :json
        assert_response :success
        # HTML uses the viewer's time zone; the API encodes these same instants
        # in UTC. Both are parsed into dates by the record store.
        assert_equal normalize_times(response.parsed_body.except('meta')), normalize_times(records)
      end
    end
  end

  test 'reply links preload their focused window and cannot select another threads records' do
    authenticate(users(:member_normal))
    discussion = discussions(:discussion)
    comment = CommentService.create(comment: Comment.new(parent: discussion, body: 'Linked reply'), actor: users(:admin))
    sequence_id = comment.created_topic_item.sequence_id
    ["/d/#{discussion.key}?comment_id=#{comment.id}", "/d/#{discussion.key}/comment/#{comment.id}", "/d/#{discussion.key}/thread/#{sequence_id}"].each do |path|
      get path, headers: {'User-Agent' => 'Mozilla/5.0 Chrome/130.0.0.0 Safari/537.36'}
      assert_response :success
      request = initial_data['requests'].find { |row| row['params'].key?('discussion_key') }
      assert_includes request['records']['comments'].pluck('id'), comment.id
      get request['path'], params: request['params'], as: :json
      assert_equal normalize_times(response.parsed_body.except('meta')), normalize_times(request['records'])
    end

    secret = CommentService.create(comment: Comment.new(parent: discussions(:alien_discussion), body: 'Private foreign reply'), actor: users(:alien))
    get "/d/#{discussion.key}?comment_id=#{secret.id}", headers: {'User-Agent' => 'Mozilla/5.0 Chrome/130.0.0.0 Safari/537.36'}
    assert_response :not_found
    refute_includes response.body, secret.body
    assert_select '#initial-data', count: 0
  end

  private

  def browser_headers
    {'User-Agent' => 'Mozilla/5.0 Chrome/130.0.0.0 Safari/537.36'}
  end

  def authenticate(user)
    token = LoginToken.create!(user: user)
    post '/api/v1/sessions', params: {user: {email: user.email, code: token.code}}, as: :json
    assert_response :success
    assert_equal user.id, response.parsed_body['current_user_id']
  end

  def initial_data
    JSON.parse(Nokogiri::HTML(response.body).at_css('#initial-data').text)
  end

  def page_topics
    initial_data['requests'].find { |request| request['path'] == '/api/v1/topics' && !request['params'].key?('last_activity_gte') }['records']['topics']
  end

  def normalize_times(records)
    records.deep_transform_values do |value|
      value.is_a?(String) && value.match?(/\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/) ? Time.iso8601(value).utc.iso8601(3) : value
    end
  end
end
