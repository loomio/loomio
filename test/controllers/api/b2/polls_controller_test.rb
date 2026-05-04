require 'test_helper'

class Api::B2::PollsControllerTest < ActionController::TestCase
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

  test "index returns active polls in the group" do
    make_poll(title: 'open one', group: @group)
    make_poll(title: 'closed one', group: @group, closed_at: 1.day.ago)
    @member.update_columns(api_key: "mkey#{SecureRandom.hex(8)}")
    get :index, params: { group_id: @group.id, api_key: @member.api_key }
    assert_response 200
    titles = JSON.parse(response.body)['polls'].map { |p| p['title'] }
    assert_includes titles, 'open one'
    refute_includes titles, 'closed one'
  end

  test "index status=closed returns closed polls" do
    make_poll(title: 'open one', group: @group)
    make_poll(title: 'closed one', group: @group, closed_at: 1.day.ago)
    @member.update_columns(api_key: "mkey#{SecureRandom.hex(8)}")
    get :index, params: { group_id: @group.id, api_key: @member.api_key, status: 'closed' }
    assert_response 200
    titles = JSON.parse(response.body)['polls'].map { |p| p['title'] }
    assert_equal ['closed one'], titles
  end

  test "index status=all returns kept polls regardless of closed_at" do
    make_poll(title: 'open one', group: @group)
    make_poll(title: 'closed one', group: @group, closed_at: 1.day.ago)
    @member.update_columns(api_key: "mkey#{SecureRandom.hex(8)}")
    get :index, params: { group_id: @group.id, api_key: @member.api_key, status: 'all' }
    assert_response 200
    titles = JSON.parse(response.body)['polls'].map { |p| p['title'] }
    assert_includes titles, 'open one'
    assert_includes titles, 'closed one'
  end

  test "index respects limit pagination" do
    3.times { |i| make_poll(title: "poll #{i}", group: @group) }
    @member.update_columns(api_key: "mkey#{SecureRandom.hex(8)}")
    get :index, params: { group_id: @group.id, api_key: @member.api_key, limit: 2 }
    assert_response 200
    assert_equal 2, JSON.parse(response.body)['polls'].size
  end

  test "index still accepts legacy per param" do
    3.times { |i| make_poll(title: "poll #{i}", group: @group) }
    @member.update_columns(api_key: "mkey#{SecureRandom.hex(8)}")
    get :index, params: { group_id: @group.id, api_key: @member.api_key, per: 2 }
    assert_response 200
    assert_equal 2, JSON.parse(response.body)['polls'].size
  end

  test "index respects offset pagination" do
    3.times { |i| make_poll(title: "poll #{i}", group: @group) }
    @member.update_columns(api_key: "mkey#{SecureRandom.hex(8)}")
    get :index, params: { group_id: @group.id, api_key: @member.api_key, limit: 2, offset: 1 }
    assert_response 200
    assert_equal 2, JSON.parse(response.body)['polls'].size
  end

  test "index rejects non-member" do
    hex = SecureRandom.hex(4)
    stranger = User.create!(name: "stranger#{hex}", email: "stranger#{hex}@example.com", username: "stranger#{hex}", email_verified: true)
    stranger.update_columns(api_key: "strkey#{SecureRandom.hex(8)}")
    get :index, params: { group_id: @group.id, api_key: stranger.api_key }
    assert_response 403
  end

  test "index allows global admin not in group" do
    admin = users(:admin)
    admin.update!(is_admin: true)
    admin.update_columns(api_key: "gadmkey#{SecureRandom.hex(8)}")
    get :index, params: { group_id: @group.id, api_key: admin.api_key }
    assert_response 200
  end

  test "index rejects bad api_key" do
    get :index, params: { group_id: @group.id, api_key: 'nope' }
    assert_response 403
  end

  test "index missing group_id returns 404" do
    @member.update_columns(api_key: "mkey#{SecureRandom.hex(8)}")
    get :index, params: { api_key: @member.api_key }
    assert_response 404
  end

  test "index response has no duplicate top-level keys" do
    make_poll(title: 'open one', group: @group)
    @member.update_columns(api_key: "mkey#{SecureRandom.hex(8)}")
    get :index, params: { group_id: @group.id, api_key: @member.api_key }
    assert_response 200
    body = response.body
    %w[polls discussions groups users events stances outcomes poll_options].each do |key|
      count = body.scan(/"#{key}":/).size
      assert count <= 1, "Expected '#{key}' key to appear at most once in response body, got #{count}"
    end
  end

  private

  def make_poll(group:, title: "test poll #{SecureRandom.hex(4)}", closed_at: nil)
    poll = PollService.create(params: {
      poll_type: 'poll',
      title: title,
      group_id: group.id,
      poll_option_names: ['engage'],
      closing_at: 3.days.from_now,
      notify_on_closing_soon: 'nobody'
    }, actor: @admin)
    poll.update!(closed_at: closed_at) if closed_at
    poll
  end
end
