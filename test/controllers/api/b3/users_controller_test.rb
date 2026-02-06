require 'test_helper'

class Api::B3::UsersControllerTest < ActionController::TestCase
  setup do
    hex = SecureRandom.hex(4)
    @user = User.create!(name: "b3user#{hex}", email: "b3user#{hex}@example.com", username: "b3user#{hex}", email_verified: true)
    ENV['B3_API_KEY'] = '12345678901234567890'
  end

  test "deactivate happy case" do
    post :deactivate, params: { b3_api_key: '12345678901234567890', id: @user.id }
    assert_response 200
    json = JSON.parse(response.body)
    assert_equal 'ok', json['success']
    assert @user.reload.deactivated_at.present?
  end

  test "cannot deactivate deactivated user" do
    @user.update_column(:deactivated_at, DateTime.now)
    post :deactivate, params: { b3_api_key: '12345678901234567890', id: @user.id }
    assert_response 404
  end

  test "deactivate incorrect key" do
    post :deactivate, params: { b3_api_key: '09876543210987654321', id: @user.id }
    assert_response 403
    refute @user.reload.deactivated_at.present?
  end

  test "deactivate blank key" do
    post :deactivate, params: { b3_api_key: '', id: @user.id }
    assert_response 403
    refute @user.reload.deactivated_at.present?
  end

  test "deactivate nil key" do
    post :deactivate, params: { id: @user.id }
    assert_response 403
    refute @user.reload.deactivated_at.present?
  end

  test "reactivate happy case" do
    @user.update_column(:deactivated_at, DateTime.now)
    post :reactivate, params: { b3_api_key: '12345678901234567890', id: @user.id }
    assert_response 200
    json = JSON.parse(response.body)
    assert_equal 'ok', json['success']
    refute @user.reload.deactivated_at.present?
  end

  test "cannot reactivate activated user" do
    post :reactivate, params: { b3_api_key: '12345678901234567890', id: @user.id }
    assert_response 404
  end
end
