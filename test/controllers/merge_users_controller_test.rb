require 'test_helper'

class MergeUsersControllerTest < ActionController::TestCase
  setup do
    @source_user = users(:normal_user)
    @target_user = users(:another_user)
    MergeUsersService.prep_for_merge!(source_user: @source_user, target_user: @target_user)
  end

  test "confirm with valid hash renders page" do
    get :confirm, params: {
      source_id: @source_user.id,
      target_id: @target_user.id,
      hash: MergeUsersService.build_merge_hash(source_user: @source_user, target_user: @target_user)
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

  test "merge with valid hash succeeds" do
    get :merge, params: {
      source_id: @source_user.id,
      target_id: @target_user.id,
      hash: MergeUsersService.build_merge_hash(source_user: @source_user, target_user: @target_user)
    }
    assert_response 200
  end

  test "merge with invalid hash returns 422" do
    get :merge, params: {
      source_id: @source_user.id,
      target_id: @target_user.id,
      hash: 'invalid hash'
    }
    assert_response 422
  end
end
