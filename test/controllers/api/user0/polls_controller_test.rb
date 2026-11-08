require 'test_helper'

class Api::User0::PollsControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    @member = users(:member)
    @group = groups(:group)

    hex = SecureRandom.hex(4)
    @bot = User.create!(name: "bot#{hex}", email: "bot#{hex}@example.com", username: "bot#{hex}", email_verified: true, bot: true)
    @bot.update_columns(api_key: "botkey#{SecureRandom.hex(8)}")
    @group.add_admin!(@bot)
    ActionMailer::Base.deliveries.clear
  end

  test "show returns the requested private poll only to authorized active API users" do
    record = PollService.create(params: { topic_id: topics(:discussion_topic).id, title: 'Private API poll', poll_type: 'proposal', poll_option_names: ['Yes', 'No'], closing_at: 3.days.from_now }, actor: users(:admin))
    %i[member_normal guest_normal former_member_guest alien former_member_loud server_admin inactive_member_loud].each do |role|
      actor = users(role)
      actor.update_columns(api_key: "show-poll-#{SecureRandom.hex(8)}")
      @request.headers['Authorization'] = "Bearer #{actor.api_key}"

      get :show, params: { id: record.id }

      if %i[member_normal guest_normal former_member_guest].include?(role)
        assert_response :success
        payload = response.parsed_body.fetch('polls').first
        assert_equal record.id, payload.fetch('id'), role.to_s
        assert_equal record.title, payload.fetch('title'), role.to_s
      else
        assert_response :forbidden
        refute_includes response.body, record.title, role.to_s
      end
    end
  end

  test "create happy case no notifications" do
    post :create, params: {
      group_id: @group.id,
      title: 'test',
      poll_type: 'proposal',
      closing_at: 3.days.from_now.iso8601,
      options: ['agree', 'disagree'],
      api_key: @bot.api_key
    }
    assert_response 200
    json = JSON.parse(response.body)
    poll = json['polls'][0]
    assert poll['id'].present?
    assert_equal @group.id, poll['group_id']
    assert_equal 'test', poll['title']
    refute_includes Poll.find(poll['id']).voters, @bot
    assert_includes Poll.find(poll['id']).voters, @admin
    assert_includes Poll.find(poll['id']).voters, @member
  end

  test "create happy case notify email" do
    post :create, params: {
      group_id: @group.id,
      title: 'test',
      poll_type: 'proposal',
      closing_at: 3.days.from_now.iso8601,
      options: ['agree', 'disagree'],
      recipient_emails: ['test@example.com'],
      api_key: @bot.api_key
    }
    assert_response 200
    json = JSON.parse(response.body)
    poll = json['polls'][0]
    assert poll['id'].present?
    assert_equal @group.id, poll['group_id']
    assert_equal 'test', poll['title']
    assert_equal 1, Poll.find(poll['id']).voters.where(email: 'test@example.com').count
  end

  test "create happy case notify user_id" do
    post :create, params: {
      group_id: @group.id,
      title: 'test',
      poll_type: 'proposal',
      closing_at: 3.days.from_now.iso8601,
      options: ['agree', 'disagree'],
      recipient_user_ids: [@member.id],
      api_key: @bot.api_key
    }
    assert_response 200
    json = JSON.parse(response.body)
    poll = json['polls'][0]
    assert poll['id'].present?
    assert_equal @group.id, poll['group_id']
    assert_equal 'test', poll['title']
    assert_equal 1, Poll.find(poll['id']).voters.where(id: @member.id).count
  end

  test "create happy case notify group" do
    post :create, params: {
      group_id: @group.id,
      title: 'test',
      poll_type: 'proposal',
      closing_at: 3.days.from_now.iso8601,
      options: ['agree', 'disagree'],
      recipient_audience: 'group',
      api_key: @bot.api_key
    }
    assert_response 200
    json = JSON.parse(response.body)
    poll = json['polls'][0]
    assert poll['id'].present?
    assert_equal @group.id, poll['group_id']
    assert_equal 'test', poll['title']
    assert_equal @group.members.humans.count, Poll.find(poll['id']).voters.count
  end

  test "create missing group id" do
    post :create, params: { title: 'test', api_key: @bot.api_key }
    assert_response 422
  end

  test "create incorrect group id" do
    bad_group = groups(:alien_group)
    post :create, params: {
      group_id: bad_group.id,
      title: 'test',
      poll_type: 'proposal',
      closing_at: 3.days.from_now.iso8601,
      options: ['agree', 'disagree'],
      recipient_audience: 'group',
      api_key: @bot.api_key
    }
    assert_response 403
  end

  test "create incorrect key" do
    post :create, params: {
      group_id: @group.id,
      title: 'test',
      poll_type: 'proposal',
      closing_at: 3.days.from_now.iso8601,
      options: ['agree', 'disagree'],
      recipient_audience: 'group',
      api_key: '1234'
    }
    assert_response 403
  end

  test "create missing key" do
    post :create, params: {
      group_id: @group.id,
      title: 'test',
      poll_type: 'proposal',
      closing_at: 3.days.from_now.iso8601,
      options: ['agree', 'disagree'],
      recipient_audience: 'group'
    }
    assert_includes [400, 403], response.status, "Expected 400 or 403 but got #{response.status}"
  end

  test "create blank key" do
    post :create, params: {
      group_id: @group.id,
      title: 'test',
      poll_type: 'proposal',
      recipient_audience: 'group',
      closing_at: 3.days.from_now.iso8601,
      options: ['agree', 'disagree'],
      api_key: ''
    }
    assert_response 403
  end

  test "update happy case" do
    poll = make_poll(group: @group, title: 'Original poll')
    @admin.update_columns(api_key: "adminkey#{SecureRandom.hex(8)}")

    patch :update, params: {
      id: poll.id,
      title: 'Updated poll',
      details: 'Updated details',
      details_format: 'md',
      api_key: @admin.api_key
    }

    assert_response 200
    poll.reload
    assert_equal 'Updated poll', poll.title
    assert_equal 'Updated details', poll.details
    assert_equal 'Updated poll', json['polls'][0]['title']
  end

  test "update missing permission" do
    poll = make_poll(group: @group, title: 'Original poll')
    @member.update_columns(api_key: "mkey#{SecureRandom.hex(8)}")

    patch :update, params: {
      id: poll.id,
      title: 'Blocked update',
      api_key: @member.api_key
    }

    assert_response 403
    refute_equal 'Blocked update', poll.reload.title
  end

  test "destroy soft deletes poll" do
    poll = make_poll(group: @group, title: 'Delete me')
    @admin.update_columns(api_key: "adminkey#{SecureRandom.hex(8)}")

    delete :destroy, params: {
      id: poll.id,
      api_key: @admin.api_key
    }

    assert_response 200
    poll.reload
    assert poll.discarded_at.present?
    assert_equal @admin.id, poll.discarded_by
    assert json['polls'][0]['discarded_at'].present?
  end

  test "index returns active polls in the group" do
    make_poll(title: 'open one', group: @group)
    make_poll(title: 'closed one', group: @group, closed_at: 1.day.ago)
    @member.update_columns(api_key: "mkey#{SecureRandom.hex(8)}")
    @request.headers['Authorization'] = "Bearer #{@member.api_key}"
    get :index, params: { group_id: @group.id }
    assert_response 200
    titles = JSON.parse(response.body)['polls'].map { |p| p['title'] }
    assert_includes titles, 'open one'
    refute_includes titles, 'closed one'
  end

  test "index status=closed returns closed polls" do
    make_poll(title: 'open one', group: @group)
    make_poll(title: 'closed one', group: @group, closed_at: 1.day.ago)
    @member.update_columns(api_key: "mkey#{SecureRandom.hex(8)}")
    @request.headers['Authorization'] = "Bearer #{@member.api_key}"
    get :index, params: { group_id: @group.id, status: 'closed' }
    assert_response 200
    titles = JSON.parse(response.body)['polls'].map { |p| p['title'] }
    assert_equal ['closed one'], titles
  end

  test "index status=all returns kept polls regardless of closed_at" do
    make_poll(title: 'open one', group: @group)
    make_poll(title: 'closed one', group: @group, closed_at: 1.day.ago)
    @member.update_columns(api_key: "mkey#{SecureRandom.hex(8)}")
    @request.headers['Authorization'] = "Bearer #{@member.api_key}"
    get :index, params: { group_id: @group.id, status: 'all' }
    assert_response 200
    titles = JSON.parse(response.body)['polls'].map { |p| p['title'] }
    assert_includes titles, 'open one'
    assert_includes titles, 'closed one'
  end

  test "index includes discussion polls with their topic and current outcome for each status" do
    topic = topics(:discussion_topic)
    open_poll = make_poll(group: @group, topic: topic, title: 'Discussion open poll')
    closed_poll = make_poll(group: @group, topic: topic, title: 'Discussion closed poll', closed_at: 1.day.ago)
    outcome = OutcomeService.create(outcome: Outcome.new(poll: closed_poll, statement: 'Consented'), actor: @admin)
    discarded_poll = make_poll(group: @group, topic: topic, title: 'Discarded discussion poll')
    PollService.discard(poll: discarded_poll, actor: @admin)
    standalone_poll = make_poll(group: @group, title: 'Standalone poll')
    @request.headers['Authorization'] = "Bearer #{@bot.api_key}"

    {
      'active' => [open_poll.id, standalone_poll.id],
      'closed' => [closed_poll.id],
      'all' => [open_poll.id, closed_poll.id, standalone_poll.id]
    }.each do |status, expected_ids|
      get :index, params: { group_id: @group.id, status: status, limit: 250 }

      assert_response :success
      assert_equal expected_ids.sort, json.fetch('polls').pluck('id').sort, status
      assert_equal expected_ids.size, json.fetch('meta').fetch('total'), status
      json.fetch('polls').reject { |poll| poll.fetch('id') == standalone_poll.id }.each do |poll|
        assert_equal topic.id, poll.fetch('topic_id')
      end
      if expected_ids.include?(closed_poll.id)
        assert_equal outcome.id, json.fetch('polls').find { |poll| poll.fetch('id') == closed_poll.id }.fetch('current_outcome_id')
        assert_equal 'Consented', json.fetch('outcomes').find { |record| record.fetch('id') == outcome.id }.fetch('statement')
      end
    end
  end

  test "index applies topic visibility to discussion polls for the access-control matrix" do
    @group.update!(group_privacy: 'closed', discussion_privacy_options: 'public_or_private')
    private_poll = make_poll(group: @group, topic: topics(:discussion_topic), title: 'Private discussion poll')
    public_poll = make_poll(group: @group, title: 'Public control poll', private: false)

    %i[admin member_normal member_guest_loud guest_normal guest_admin_normal former_member_guest alien non_guest_loud former_guest_loud former_member_loud server_admin inactive_member_loud].each do |role|
      actor = users(role)
      actor.update_columns(api_key: "index-poll-#{SecureRandom.hex(8)}")
      @request.headers['Authorization'] = "Bearer #{actor.api_key}"

      get :index, params: { group_id: @group.id, status: 'all' }

      if role == :inactive_member_loud
        assert_response :forbidden
        refute_includes response.body, private_poll.title
        next
      end

      assert_response :success
      expected_ids = [public_poll.id]
      expected_ids << private_poll.id if %i[admin member_normal member_guest_loud guest_normal guest_admin_normal former_member_guest].include?(role)
      assert_equal expected_ids.sort, json.fetch('polls').pluck('id').sort, role.to_s
      assert_equal expected_ids.size, json.fetch('meta').fetch('total'), role.to_s
      refute_includes response.body, private_poll.title unless expected_ids.include?(private_poll.id)
    end
  end

  test "index excludes polls in other groups, direct threads and discarded topics" do
    group_poll = make_poll(group: @group, topic: topics(:discussion_topic))
    subgroup_poll = make_poll(group: groups(:subgroup), topic: topics(:subgroup_discussion_topic))
    direct_poll = PollService.create(params: {
      topic_id: topics(:direct_topic).id, title: 'Direct discussion poll', poll_type: 'poll',
      poll_option_names: ['engage'], closing_at: 3.days.from_now
    }, actor: users(:guest_admin_normal))
    TopicReader.for(user: @admin, topic: direct_poll.topic).update!(guest: true)
    discarded_topic_poll = make_poll(group: @group)
    discarded_topic_poll.topic.update!(discarded_at: Time.current)
    @admin.update_columns(api_key: "adminkey#{SecureRandom.hex(8)}")
    @request.headers['Authorization'] = "Bearer #{@admin.api_key}"
    assert @admin.can?(:show, subgroup_poll)
    assert @admin.can?(:show, direct_poll)

    get :index, params: { group_id: @group.id, status: 'all' }

    assert_response :success
    assert_equal [group_poll.id], json.fetch('polls').pluck('id')
    assert_equal 1, json.fetch('meta').fetch('total')
  end

  test "index preserves result visibility for open and closed discussion polls" do
    @request.headers['Authorization'] = "Bearer #{@bot.api_key}"
    [false, true].each do |anonymous|
      poll = PollService.create(params: {
        topic_id: topics(:discussion_topic).id, title: 'Discussion result visibility', poll_type: 'poll',
        anonymous: anonymous, poll_option_names: ['engage'], closing_at: 3.days.from_now
      }, actor: @admin)

      (anonymous ? %w[until_closed] : %w[off until_vote until_closed]).each do |hide_results|
        [nil, Time.current].each do |closed_at|
          poll.update_columns(hide_results: hide_results, closed_at: closed_at)

          get :index, params: { group_id: @group.id, status: 'all' }

          assert_response :success
          payload = json.fetch('polls').find { |record| record.fetch('id') == poll.id }
          assert payload, "anonymous=#{anonymous}, hide_results=#{hide_results}, closed=#{closed_at.present?}"
          results_visible = hide_results != 'until_closed' || closed_at.present?
          %w[results scores_by_option total_score].each do |field|
            assert_equal results_visible, payload.key?(field), field
          end
          if anonymous && closed_at.nil?
            %w[vote_count_cast vote_count_uncast participation_pct quorum_reached quorum_shortfall].each do |field|
              assert_not payload.key?(field), field
            end
          end
        end
      end
    end
  end

  test "index respects limit pagination" do
    3.times { |i| make_poll(title: "poll #{i}", group: @group) }
    @member.update_columns(api_key: "mkey#{SecureRandom.hex(8)}")
    @request.headers['Authorization'] = "Bearer #{@member.api_key}"
    get :index, params: { group_id: @group.id, limit: 2 }
    assert_response 200
    assert_equal 2, JSON.parse(response.body)['polls'].size
  end

  test "index still accepts legacy per param" do
    3.times { |i| make_poll(title: "poll #{i}", group: @group) }
    @member.update_columns(api_key: "mkey#{SecureRandom.hex(8)}")
    @request.headers['Authorization'] = "Bearer #{@member.api_key}"
    get :index, params: { group_id: @group.id, per: 2 }
    assert_response 200
    assert_equal 2, JSON.parse(response.body)['polls'].size
  end

  test "index respects offset pagination" do
    3.times { |i| make_poll(title: "poll #{i}", group: @group) }
    @member.update_columns(api_key: "mkey#{SecureRandom.hex(8)}")
    @request.headers['Authorization'] = "Bearer #{@member.api_key}"
    get :index, params: { group_id: @group.id, limit: 2, offset: 1 }
    assert_response 200
    assert_equal 2, JSON.parse(response.body)['polls'].size
  end

  test "index lets a non-member read public polls without exposing private polls" do
    public_group = Group.create!(
      name: "Public Group #{SecureRandom.hex(4)}",
      group_privacy: "closed",
      discussion_privacy_options: "public_or_private"
    )
    Membership.create!(user: @admin, group: public_group, accepted_at: Time.current, admin: true)
    public_poll = make_poll(group: public_group, title: "Public Poll", private: false)
    private_poll = make_poll(group: public_group, title: "Private Poll", private: true)
    stranger = create_user_with_api_key!

    @request.headers['Authorization'] = "Bearer #{stranger.api_key}"
    get :index, params: { group_id: public_group.id, status: "all" }

    assert_response :success
    poll_ids = json.fetch("polls").pluck("id")
    assert_equal [ public_poll.id ], poll_ids
    refute_includes response.body, private_poll.title
  end

  test "index rejects a non-member of a private group" do
    stranger = create_user_with_api_key!

    @request.headers['Authorization'] = "Bearer #{stranger.api_key}"
    get :index, params: { group_id: @group.id }

    assert_response 403
  end

  test "index does not grant an instance admin access to a private group" do
    admin = create_user_with_api_key!
    admin.update!(is_admin: true)
    @request.headers['Authorization'] = "Bearer #{admin.api_key}"
    get :index, params: { group_id: @group.id }
    assert_response :forbidden
  end

  test "index rejects bad api_key" do
    @request.headers['Authorization'] = 'Bearer nope'
    get :index, params: { group_id: @group.id }
    assert_response 403
  end

  test "index missing group_id returns 404" do
    @member.update_columns(api_key: "mkey#{SecureRandom.hex(8)}")
    @request.headers['Authorization'] = "Bearer #{@member.api_key}"
    get :index
    assert_response 404
  end

  test "index response has no duplicate top-level keys" do
    make_poll(title: 'open one', group: @group)
    @member.update_columns(api_key: "mkey#{SecureRandom.hex(8)}")
    @request.headers['Authorization'] = "Bearer #{@member.api_key}"
    get :index, params: { group_id: @group.id }
    assert_response 200
    body = response.body
    %w[polls discussions groups users topic_items stances outcomes poll_options].each do |key|
      count = body.scan(/"#{key}":/).size
      assert count <= 1, "Expected '#{key}' key to appear at most once in response body, got #{count}"
    end
  end

  private

  def create_user_with_api_key!
    hex = SecureRandom.hex(4)
    User.create!(name: "stranger#{hex}", email: "stranger#{hex}@example.com", username: "stranger#{hex}", email_verified: true).tap do |user|
      user.update_columns(api_key: "strkey#{SecureRandom.hex(8)}")
    end
  end

  def make_poll(group:, title: "test poll #{SecureRandom.hex(4)}", closed_at: nil, private: nil, topic: nil)
    params = {
      poll_type: 'poll',
      title: title,
      group_id: group.id,
      poll_option_names: ['engage'],
      closing_at: 3.days.from_now,
      notify_on_closing_soon: 'nobody'
    }
    params[:topic_id] = topic.id if topic
    params[:private] = private unless private.nil?
    poll = PollService.create(params: params, actor: @admin)
    poll.update!(closed_at: closed_at) if closed_at
    poll
  end

  def json
    JSON.parse(response.body)
  end
end
