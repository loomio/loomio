require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    sign_in @admin
  end

  test "show renders memberships with a missing group" do
    user = users(:user)
    membership = memberships(:user_membership)
    missing_group_id = Group.maximum(:id) + 100
    membership.update_columns(group_id: missing_group_id)

    get :show, params: { id: user.id }

    assert_response :success
    assert_includes response.body, "Missing group ##{missing_group_id}"
  end
end
