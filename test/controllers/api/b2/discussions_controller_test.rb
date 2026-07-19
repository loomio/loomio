require 'test_helper'

class Api::B2::DiscussionsControllerTest < ActionController::TestCase
  setup do
    @user = users(:user)
    @group = groups(:group)
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

  test "create defaults to public when the group requires public discussions" do
    group = Group.create!(
      name: "Open Group #{SecureRandom.hex(4)}",
      group_privacy: 'open'
    )
    Membership.create!(user: @user, group: group, accepted_at: Time.current, admin: true)

    post :create, params: { title: 'test', group_id: group.id, api_key: @user.api_key }

    assert_response :success
    discussion = Discussion.find(json['discussions'][0]['id'])
    assert_equal false, discussion.topic.private
  end

  test "create returns validation errors when privacy is not permitted by the group" do
    group = Group.create!(
      name: "Open Group #{SecureRandom.hex(4)}",
      group_privacy: 'open'
    )
    Membership.create!(user: @user, group: group, accepted_at: Time.current, admin: true)

    assert_no_difference ['Discussion.count', 'Topic.count'] do
      post :create, params: {
        title: 'test',
        group_id: group.id,
        private: true,
        api_key: @user.api_key
      }
    end

    assert_response :unprocessable_entity
    assert_equal ['must be public'], json.dig('errors', 'private')
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

  test "update happy case" do
    discussion = DiscussionService.create(params: { title: 'Original title', group_id: @group.id }, actor: @user)

    patch :update, params: {
      id: discussion.id,
      title: 'Updated title',
      description: 'Updated description',
      description_format: 'md',
      api_key: @user.api_key
    }

    assert_response 200
    discussion.reload
    assert_equal 'Updated title', discussion.title
    assert_equal 'Updated description', discussion.description
    assert_equal 'Updated title', json['discussions'][0]['title']
  end

  test "update missing permission" do
    discussion = DiscussionService.create(params: { title: 'Original title', group_id: @group.id }, actor: @user)
    outsider = create_user_with_api_key!

    patch :update, params: {
      id: discussion.id,
      title: 'Blocked update',
      api_key: outsider.api_key
    }

    assert_response 403
    refute_equal 'Blocked update', discussion.reload.title
  end

  test "destroy soft deletes discussion" do
    discussion = DiscussionService.create(params: { title: 'Delete me', group_id: @group.id }, actor: @user)

    delete :destroy, params: {
      id: discussion.id,
      api_key: @user.api_key
    }

    assert_response 200
    discussion.reload
    assert discussion.discarded_at.present?
    assert_equal @user.id, discussion.discarded_by
    assert json['discussions'][0]['discarded_at'].present?
  end

  test "index returns open discussions in the group" do
    private_d = DiscussionService.create(params: { title: 'Private Discussion', group_id: @group.id, private: true }, actor: @user)
    discarded_d = DiscussionService.create(params: { title: 'Discarded Discussion', group_id: @group.id, private: true }, actor: @user)
    discarded_d.update!(discarded_at: Time.now)
    get :index, params: { group_id: @group.id, api_key: @user.api_key }
    assert_response 200
    json = JSON.parse(response.body)
    titles = json['discussions'].map { |d| d['title'] }
    assert_includes titles, 'Test Discussion'
    assert_includes titles, 'Private Discussion'
    refute_includes titles, 'Discarded Discussion'
  end

  test "index status=closed returns closed discussions only" do
    discussions(:discussion).topic.update!(locked_at: Time.now)
    get :index, params: { group_id: @group.id, api_key: @user.api_key, status: 'closed' }
    assert_response 200
    titles = JSON.parse(response.body)['discussions'].map { |d| d['title'] }
    assert_equal ['Test Discussion'], titles
  end

  test "index status=all includes closed and open but not discarded" do
    discussions(:discussion).topic.update!(locked_at: Time.now)
    private_d = DiscussionService.create(params: { title: 'Private Discussion', group_id: @group.id, private: true }, actor: @user)
    discarded_d = DiscussionService.create(params: { title: 'Discarded Discussion', group_id: @group.id, private: true }, actor: @user)
    discarded_d.update!(discarded_at: Time.now)
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

  private

  def create_user_with_api_key!
    hex = SecureRandom.hex(4)
    User.create!(name: "stranger#{hex}", email: "stranger#{hex}@example.com", username: "stranger#{hex}", email_verified: true).tap do |user|
      user.update_columns(api_key: "strkey#{SecureRandom.hex(8)}")
    end
  end

  def json
    JSON.parse(response.body)
  end
end
