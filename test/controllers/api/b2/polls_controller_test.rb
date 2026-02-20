require 'test_helper'

class Api::B2::PollsControllerTest < ActionController::TestCase
  setup do
    @admin = users(:group_admin)
    @member = users(:another_user)
    @group = groups(:test_group)

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
    bad_group = groups(:another_group)
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
      closing_at: 3.days.from_now.iso8601,
      options: ['agree', 'disagree'],
      recipient_audience: 'group',
      api_key: ''
    }
    assert_response 403
  end
end
