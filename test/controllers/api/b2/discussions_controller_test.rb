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
end
