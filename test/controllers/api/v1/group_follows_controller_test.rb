require "test_helper"

class Api::V1::GroupFollowsControllerTest < ActionController::TestCase
  setup do
    @user = users(:alien)
    @group = groups(:public_group)
    sign_in @user
  end

  test "verified non-member follows and unfollows a public-only group" do
    assert_difference "GroupFollow.count", 1 do
      post :create, params: { group_id: @group.id }
    end
    assert_response :success
    assert_equal true, response.parsed_body.fetch("groups").first.fetch("current_user_followed")

    assert_difference "GroupFollow.count", -1 do
      delete :destroy, params: { id: @group.id }
    end
    assert_response :success
    assert_equal false, response.parsed_body.fetch("groups").first.fetch("current_user_followed")
  end

  test "cannot follow a group whose discussions are not public-only" do
    assert_no_difference "GroupFollow.count" do
      post :create, params: { group_id: groups(:alien_group).id }
    end

    assert_response :forbidden
  end

  test "unverified user cannot follow" do
    @user.update!(email_verified: false)

    assert_no_difference "GroupFollow.count" do
      post :create, params: { group_id: @group.id }
    end

    assert_response :forbidden
  end

  test "member cannot follow" do
    @group.add_member!(@user)

    assert_no_difference "GroupFollow.count" do
      post :create, params: { group_id: @group.id }
    end

    assert_response :forbidden
  end
end
