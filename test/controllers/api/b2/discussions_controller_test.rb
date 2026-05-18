require 'test_helper'

class Api::B2::DiscussionsControllerTest < ActionController::TestCase
  setup do
    @user = users(:normal_user)
    @group = groups(:test_group)
    @group.add_admin!(@user)
    @user.update_columns(api_key: "apikey#{SecureRandom.hex(8)}")
    ActionMailer::Base.deliveries.clear
  end

  test "create happy case" do
    post :create, params: { title: 'test', group_id: @group.id, api_key: @user.api_key }
    assert_response 200
    json = JSON.parse(response.body)
    discussion = json['discussions'][0]
    assert discussion['id'].present?
    assert_equal @group.id, discussion['group_id']
    assert_equal 'test', discussion['title']
  end

  test "create happy case notify group" do
    post :create, params: { title: 'test', group_id: @group.id, api_key: @user.api_key, recipient_audience: 'group' }
    assert_response 200
    json = JSON.parse(response.body)
    discussion = json['discussions'][0]
    assert discussion['id'].present?
    assert_equal @group.id, discussion['group_id']
    assert_equal 'test', discussion['title']
    assert_equal @group.members.humans.count, Discussion.find(discussion['id']).readers.count
  end

  test "create missing permission - revoked" do
    Membership.where(group_id: @group.id, user_id: @user.id).update(revoked_at: Time.now)
    post :create, params: { title: 'test', group_id: @group.id, api_key: @user.api_key }
    assert_response 403
  end

  test "create missing permission - deleted" do
    Membership.where(group_id: @group.id, user_id: @user.id).delete_all
    post :create, params: { title: 'test', group_id: @group.id, api_key: @user.api_key }
    assert_response 403
  end

  test "create incorrect key" do
    post :create, params: { title: 'test', group_id: @group.id, api_key: 1234 }
    assert_response 403
  end

  test "create blank key" do
    post :create, params: { title: 'test', group_id: @group.id }
    assert_includes [400, 403], response.status, "Expected 400 or 403 but got #{response.status}"
  end

  test "index returns open discussions in the group" do
    get :index, params: { group_id: @group.id, api_key: @user.api_key }
    assert_response 200
    json = JSON.parse(response.body)
    titles = json['discussions'].map { |d| d['title'] }
    assert_includes titles, 'Test Discussion'
    assert_includes titles, 'Private Discussion'
    refute_includes titles, 'Discarded Discussion'
  end

  test "index status=closed returns closed discussions only" do
    discussions(:test_discussion).update!(closed_at: Time.now)
    get :index, params: { group_id: @group.id, api_key: @user.api_key, status: 'closed' }
    assert_response 200
    titles = JSON.parse(response.body)['discussions'].map { |d| d['title'] }
    assert_equal ['Test Discussion'], titles
  end

  test "index status=all includes closed and open but not discarded" do
    discussions(:test_discussion).update!(closed_at: Time.now)
    get :index, params: { group_id: @group.id, api_key: @user.api_key, status: 'all' }
    assert_response 200
    titles = JSON.parse(response.body)['discussions'].map { |d| d['title'] }
    assert_includes titles, 'Test Discussion'
    assert_includes titles, 'Private Discussion'
    refute_includes titles, 'Discarded Discussion'
  end

  test "index respects limit pagination" do
    get :index, params: { group_id: @group.id, api_key: @user.api_key, limit: 1 }
    assert_response 200
    assert_equal 1, JSON.parse(response.body)['discussions'].size
  end

  test "index still accepts legacy per param" do
    get :index, params: { group_id: @group.id, api_key: @user.api_key, per: 1 }
    assert_response 200
    assert_equal 1, JSON.parse(response.body)['discussions'].size
  end

  test "index rejects non-member" do
    hex = SecureRandom.hex(4)
    stranger = User.create!(name: "stranger#{hex}", email: "stranger#{hex}@example.com", username: "stranger#{hex}", email_verified: true)
    stranger.update_columns(api_key: "strkey#{SecureRandom.hex(8)}")
    get :index, params: { group_id: @group.id, api_key: stranger.api_key }
    assert_response 403
  end

  test "index allows global admin not in group" do
    admin = users(:admin_user)
    admin.update_columns(api_key: "gadmkey#{SecureRandom.hex(8)}")
    get :index, params: { group_id: @group.id, api_key: admin.api_key }
    assert_response 200
  end

  test "index rejects bad api_key" do
    get :index, params: { group_id: @group.id, api_key: 'nope' }
    assert_response 403
  end

  test "index missing group_id returns 404" do
    get :index, params: { api_key: @user.api_key }
    assert_response 404
  end

  test "index response has no duplicate top-level keys" do
    get :index, params: { group_id: @group.id, api_key: @user.api_key }
    assert_response 200
    body = response.body
    %w[discussions polls groups users events stances outcomes poll_options].each do |key|
      count = body.scan(/"#{key}":/).size
      assert count <= 1, "Expected '#{key}' key to appear at most once in response body, got #{count}"
    end
  end
end
