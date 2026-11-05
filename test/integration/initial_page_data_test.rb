require 'test_helper'

class InitialPageDataTest < ActionDispatch::IntegrationTest
  setup do
    @saved_env = %w[FEATURES_DISABLE_EMAIL_LOGIN TURNSTILE_SECRET_KEY TERMS_URL].to_h { |key| [key, ENV.delete(key)] }
  end

  teardown do
    @saved_env.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
  end

  test 'dashboard and inbox embed exactly the authorized API responses for members guests and revoked users' do
    %i[member_normal guest_normal guest_admin_normal former_member_loud former_guest_loud server_admin].each do |role|
      authenticate(users(role))
      ['/dashboard', '/inbox'].each do |path|
        get path
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
      get path
      assert_response :success
      assert_nil initial_data['boot']['current_user_id']
      assert_empty initial_data['requests']
    end
  end

  test 'inbox excludes read and dismissed threads while dashboard retains them' do
    user = users(:member_normal)
    authenticate(user)
    reader = TopicReader.for(user: user, topic: topics(:discussion_topic))
    reader.update!(last_read_at: Time.current, dismissed_at: Time.current)

    get '/inbox'
    assert_empty page_topics.select { |topic| topic['id'] == topics(:discussion_topic).id }
    get '/dashboard'
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
