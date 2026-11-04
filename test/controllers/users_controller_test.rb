require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "returns 404 for a user who doesnt exist" do
    get :show, params: { username: :undefined }
    assert_response 404
  end

  test "shows a user page titled with the user's name" do
    sign_in users(:admin)
    get :show, params: { username: users(:user).username }
    assert_response 200
    assert_includes response.body, "<title>#{ERB::Util.html_escape(users(:user).name)}</title>"
  end

  test "does not show a user page to signed-out visitors" do
    get :show, params: { username: users(:user).username }
    assert_response 403
    assert_not_includes response.body, users(:user).name
  end
end
