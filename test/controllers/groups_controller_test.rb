require 'test_helper'
require 'minitest/mock'

class GroupsControllerTest < ActionController::TestCase
  setup do
    hex = SecureRandom.hex(4)
    @user = User.create!(name: "grpuser#{hex}", email: "grpuser#{hex}@example.com", username: "grpuser#{hex}", email_verified: true)
    @group = Group.new(name: "grpctrl#{hex}", group_privacy: 'closed')
    @group.creator = @user
    @group.save!
    ActionMailer::Base.deliveries.clear
  end

  # Index tests
  test "index works" do
    get :index
    assert_response 200
  end

  test "index allows logged out when restriction disabled" do
    AppConfig.stub(:app_features, { restrict_explore_to_signed_in_users: false }) do
      get :index
      assert_response 200
    end
  end

  test "index prevents logged out when restriction enabled" do
    AppConfig.stub(:app_features, { restrict_explore_to_signed_in_users: true }) do
      get :index
      assert_response 401
    end
  end

  test "index allows signed in when restriction enabled" do
    sign_in @user
    AppConfig.stub(:app_features, { restrict_explore_to_signed_in_users: true }) do
      get :index
      assert_response 200
    end
  end

  # Show - secret group
  test "show secret group 200 for member" do
    @group.update(group_privacy: 'secret')
    @group.add_member!(@user)
    sign_in @user
    get :show, params: { key: @group.key }
    assert_response 200
    assert_equal @group, assigns(:group)
  end

  test "show 404 for non-existent group" do
    get :show, params: { key: 'doesnotexist' }
    assert_response 404
    assert_nil assigns(:group)
  end

  # Show - closed group
  test "show closed group 200 for member" do
    @group.add_member!(@user)
    sign_in @user
    get :show, params: { key: @group.key }
    assert_response 200
    assert_equal @group, assigns(:group)
  end

  test "show closed group 200 for non-logged in" do
    get :show, params: { key: @group.key }
    assert_response 200
    assert_equal @group, assigns(:group)
  end

  test "show closed group 200 for non-member" do
    sign_in @user
    get :show, params: { key: @group.key }
    assert_response 200
    assert_equal @group, assigns(:group)
  end

  test "show closed group 404 for non-existent" do
    get :show, params: { key: 'doesnotexist' }
    assert_response 404
    assert_nil assigns(:group)
  end

  # XML feeds
  test "signed in displays xml feed" do
    @group.add_member!(@user)
    sign_in @user
    get :show, params: { key: @group.key }, format: :xml
    assert_response 200
    assert_equal @group, assigns(:group)
  end

  test "displays xml feed" do
    get :show, params: { key: @group.key }, format: :xml
    assert_response 200
    assert_equal @group, assigns(:group)
  end

  test "displays xml error when group not found" do
    get :show, params: { key: :notakey }, format: :xml
    assert_response 404
  end

  # Export
  test "loads export for admin" do
    sign_in @user
    @group.add_admin!(@user)
    get :export, params: { key: @group.key }, format: :html
    assert_response 200
  end

  test "does not allow non-admins to see export" do
    sign_in @user
    get :export, params: { key: @group.key }, format: :html
    assert_response 302

    get :export, params: { key: @group.key }, format: :csv
    assert_response 302
  end
end
