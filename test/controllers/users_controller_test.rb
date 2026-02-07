require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "returns 404 for a user who doesnt exist" do
    get :show, params: { username: :undefined }
    assert_response 404
  end
end
