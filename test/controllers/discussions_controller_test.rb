require 'test_helper'

class DiscussionsControllerTest < ActionController::TestCase
  setup do
    @user = users(:user)
    @group = groups(:group)
    @discussion = discussions(:discussion)
  end

  test "show 200 ssr and boot for signed in member" do
    sign_in @user
    get :show, params: { key: @discussion.key }
    assert_response 200
    assert_equal @discussion, assigns(:discussion)
  end

  test "show 404 for non-existent discussion" do
    get :show, params: { key: 'doesnotexist' }
    assert_response 404
    assert_nil assigns(:discussion)
  end

  test "signed in displays xml feed" do
    sign_in @user
    get :show, params: { key: @discussion.key }, format: :xml
    assert_response 200
    assert_equal @discussion, assigns(:discussion)
  end

  test "signed out displays xml feed for public discussion" do
    discussion = discussions(:public_discussion)
    get :show, params: { key: discussion.key }, format: :xml
    assert_response 200
    assert_equal discussion, assigns(:discussion)
  end
end
