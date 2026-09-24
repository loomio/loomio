require 'test_helper'

class Api::V1::BootControllerTest < ActionController::TestCase
  test 'an unsubscribe token does not boot the account into the app' do
    user = users(:user)

    get :site, params: {unsubscribe_token: user.unsubscribe_token}, format: :json

    assert_response :success
    payload = JSON.parse(response.body)
    assert_nil payload['current_user_id']
    assert_nil payload['channel_token']
    refute_includes payload.fetch('users').map { |record| record['id'] }, user.id
  end

  test 'an unsubscribe token does not replace a signed-in app user' do
    token_owner = users(:user)
    signed_in_user = users(:alien)
    sign_in signed_in_user

    get :site, params: {unsubscribe_token: token_owner.unsubscribe_token}, format: :json

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal signed_in_user.id, payload['current_user_id']
    assert_equal signed_in_user.secret_token, payload['channel_token']
  end
end
