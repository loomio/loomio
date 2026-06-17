require 'test_helper'

class MergeUsersControllerTest < ActionController::TestCase
  setup do
    @source_user = users(:user)
    @target_user = users(:alien)
    sign_in @target_user
    @valid_hash = MergeUsersService.build_merge_hash(source_user: @source_user, target_user: @target_user)
  end

  teardown do
    sign_out
  end

  test "unauthenticated user is redirected" do
    sign_out
    get :confirm, params: {
      source_id: @source_user.id,
      target_id: @target_user.id,
      hash: @valid_hash
    }
    assert_response 302
  end

  test "wrong user cannot confirm" do
    sign_out
    sign_in @source_user
    get :confirm, params: {
      source_id: @source_user.id,
      target_id: @target_user.id,
      hash: @valid_hash
    }
    assert_response 302
    assert_match(/target account/, flash[:error])
  end

  test "confirm with valid hash renders page" do
    get :confirm, params: {
      source_id: @source_user.id,
      target_id: @target_user.id,
      hash: @valid_hash
    }
    assert_response 200
    assert_select "form"
  end

  test "confirm with invalid hash returns 422" do
    get :confirm, params: {
      source_id: @source_user.id,
      target_id: @target_user.id,
      hash: 'invalid hash'
    }
    assert_response 422
  end

  test "confirm remains valid after source secret token rotates" do
    @source_user.update!(secret_token: User.generate_unique_secure_token)

    get :confirm, params: {
      source_id: @source_user.id,
      target_id: @target_user.id,
      hash: @valid_hash
    }
    assert_response 200
  end

  test "merge with valid hash succeeds" do
    post :merge, params: {
      source_id: @source_user.id,
      target_id: @target_user.id,
      hash: @valid_hash
    }
    assert_response 200
  end

  test "merge hash is invalidated after first success" do
    post :merge, params: {
      source_id: @source_user.id,
      target_id: @target_user.id,
      hash: @valid_hash
    }
    assert_response 200

    # After a successful merge, the source account is deactivated immediately.
    # Replaying the same hash from a second request must not succeed.
    post :merge, params: {
      source_id: @source_user.id,
      target_id: @target_user.id,
      hash: @valid_hash
    }
    assert_includes [404, 422], @response.status
  end

  test "merge with invalid hash returns 422" do
    post :merge, params: {
      source_id: @source_user.id,
      target_id: @target_user.id,
      hash: 'invalid hash'
    }
    assert_response 422
  end

  test "wrong user cannot merge" do
    sign_out
    sign_in @source_user
    post :merge, params: {
      source_id: @source_user.id,
      target_id: @target_user.id,
      hash: @valid_hash
    }
    assert_response 302
    assert_match(/target account/, flash[:error])
  end
end
