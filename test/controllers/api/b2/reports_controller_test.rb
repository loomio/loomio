require 'test_helper'

class Api::B2::ReportsControllerTest < ActionController::TestCase
  setup do
    @user = users(:user)
    @group = groups(:group)
    @user.update_columns(api_key: "reportkey#{SecureRandom.hex(8)}")
    @request.headers['Authorization'] = "Bearer #{@user.api_key}"
  end

  test "returns delegate activity rows for groups visible to the API user" do
    @group.membership_for(@user).update!(delegate: true)

    get :index, params: {
      section: 'users',
      group_scope: 'custom',
      group_ids: @group.id,
      member_type: 'delegate'
    }

    assert_response :success
    row = JSON.parse(response.body).fetch('users').find { |record| record['id'] == @user.id }
    assert_equal true, row.fetch('delegate')
    %w[votes votes_cast votes_issued votes_missed all_votes_cast].each do |field|
      assert row.key?(field)
    end
  end

  test "does not report a group the API user cannot access" do
    alien_group = groups(:alien_group)
    alien_user = users(:alien)
    alien_group.membership_for(alien_user).update!(delegate: true)

    get :index, params: {
      section: 'users',
      group_scope: 'custom',
      group_ids: alien_group.id,
      member_type: 'delegate'
    }

    assert_response :success
    assert_empty JSON.parse(response.body).fetch('users')
  end

  test "instance admin status does not expand report scope" do
    @user.update!(is_admin: true)
    alien_group = groups(:alien_group)
    alien_user = users(:alien)
    alien_group.membership_for(alien_user).update!(delegate: true)

    get :index, params: {
      section: 'users',
      group_scope: 'custom',
      group_ids: alien_group.id,
      member_type: 'delegate'
    }

    assert_response :success
    body = JSON.parse(response.body)
    assert_empty body.fetch('users')
    assert_equal false, body.fetch('current_user_is_admin')
  end

  test "requires a valid bearer API key" do
    @request.headers['Authorization'] = 'Bearer invalid'

    get :index, params: { section: 'users', group_ids: @group.id }

    assert_response :forbidden
  end
end
