require 'test_helper'

class Api::V1::BootControllerTest < ActionController::TestCase
  test 'version prompts older clients to reload across a two-digit minor version' do
    Version.stub(:current, '3.10.0') do
      ['3.9.0', '3.9.1'].each do |version|
        get :version, params: {version: version, release: AppConfig.release}, format: :json

        assert_response :success
        payload = JSON.parse(response.body)
        assert_equal '3.10.0', payload['version']
        assert_equal true, payload['reload']
      end
    end
  end

  test 'version does not prompt current or newer clients to reload' do
    Version.stub(:current, '3.10.0') do
      ['3.10.0', '3.11.0', '4.0.0'].each do |version|
        get :version, params: {version: version, release: AppConfig.release}, format: :json

        assert_response :success
        refute JSON.parse(response.body)['reload']
      end
    end
  end

  test 'version prompts clients without a version to reload' do
    get :version, params: {release: AppConfig.release}, format: :json

    assert_response :success
    assert_equal true, JSON.parse(response.body)['reload']
  end

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
