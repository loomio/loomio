require 'test_helper'

class Api::B3::UsersControllerTest < ActionController::TestCase
  setup do
    hex = SecureRandom.hex(4)
    @api_key = '12345678901234567890'
    @user = User.create!(name: "b3user#{hex}", email: "b3user#{hex}@example.com", username: "b3user#{hex}", email_verified: true)
    @identity = @user.identities.create!(
      identity_type: 'oauth',
      uid: "external#{hex}",
      email: @user.email,
      name: @user.name
    )
    @original_b3_api_key = ENV['B3_API_KEY']
    ENV['B3_API_KEY'] = @api_key
  end

  teardown do
    ENV['B3_API_KEY'] = @original_b3_api_key
  end

  test "index returns users with identities" do
    get :index, params: { b3_api_key: @api_key }
    assert_response 200

    user = json['users'].find { |item| item['id'] == @user.id }
    assert_equal @user.name, user['name']
    assert_equal @user.username, user['username']
    assert_equal @user.email, user['email']
    assert_equal true, user['active']
    assert_nil user['deactivated_at']
    assert_equal @identity.uid, user['identities'].first['uid']
  end

  test "show returns a user" do
    get :show, params: { b3_api_key: @api_key, id: @user.id }
    assert_response 200

    assert_equal @user.id, json['user']['id']
    assert_equal @identity.uid, json['user']['identities'].first['uid']
  end

  test "show by identity returns a user" do
    get :show_by_identity, params: { b3_api_key: @api_key, identity_type: @identity.identity_type, uid: @identity.uid }
    assert_response 200

    assert_equal @user.id, json['user']['id']
  end

  test "update changes managed user fields" do
    patch :update, params: {
      b3_api_key: @api_key,
      id: @user.id,
      user: {
        name: 'Updated Name',
        username: "updated#{SecureRandom.hex(4)}",
        email: "updated#{SecureRandom.hex(4)}@example.com"
      }
    }
    assert_response 200

    @user.reload
    assert_equal 'Updated Name', @user.name
    assert_equal @user.name, json['user']['name']
  end

  test "update rejects unknown user fields" do
    patch :update, params: {
      b3_api_key: @api_key,
      id: @user.id,
      user: {
        name: 'Updated Name',
        is_admin: true
      }
    }
    assert_response 400

    @user.reload
    refute_equal 'Updated Name', @user.name
    refute @user.is_admin
  end

  test "update by identity changes managed user fields" do
    patch :update_by_identity, params: {
      b3_api_key: @api_key,
      identity_type: @identity.identity_type,
      uid: @identity.uid,
      user: { name: 'Identity Update' }
    }
    assert_response 200

    assert_equal 'Identity Update', @user.reload.name
    assert_equal @user.id, json['user']['id']
  end

  test "bearer token authenticates requests" do
    @request.headers['Authorization'] = "Bearer #{@api_key}"
    get :show, params: { id: @user.id }
    assert_response 200

    assert_equal @user.id, json['user']['id']
  end

  test "deactivate happy case" do
    post :deactivate, params: { b3_api_key: @api_key, id: @user.id }
    assert_response 200
    assert_equal true, json['success']
    assert @user.reload.deactivated_at.present?
    assert_equal false, json['user']['active']
  end

  test "cannot deactivate deactivated user" do
    @user.update_column(:deactivated_at, DateTime.now)
    post :deactivate, params: { b3_api_key: @api_key, id: @user.id }
    assert_response 404
  end

  test "deactivate by identity" do
    post :deactivate_by_identity, params: { b3_api_key: @api_key, identity_type: @identity.identity_type, uid: @identity.uid }
    assert_response 200

    assert @user.reload.deactivated_at.present?
    assert_equal false, json['user']['active']
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
    post :reactivate, params: { b3_api_key: @api_key, id: @user.id }
    assert_response 200
    assert_equal true, json['success']
    refute @user.reload.deactivated_at.present?
    assert_equal true, json['user']['active']
  end

  test "cannot reactivate activated user" do
    post :reactivate, params: { b3_api_key: @api_key, id: @user.id }
    assert_response 404
  end

  test "reactivate by identity" do
    @user.update_column(:deactivated_at, DateTime.now)
    post :reactivate_by_identity, params: { b3_api_key: @api_key, identity_type: @identity.identity_type, uid: @identity.uid }
    assert_response 200

    refute @user.reload.deactivated_at.present?
    assert_equal true, json['user']['active']
  end

  test "destroy redacts user" do
    delete :destroy, params: { b3_api_key: @api_key, id: @user.id }
    assert_response 200
    assert_equal true, json['success']

    assert_nil @user.reload.email
  end

  private

  def json
    JSON.parse(response.body)
  end
end
