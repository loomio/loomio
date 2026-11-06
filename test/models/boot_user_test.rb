require 'test_helper'

class BootUserTest < ActiveSupport::TestCase
  test "signed in users boot without their secret token" do
    user = users(:user)
    flash = ActionDispatch::Flash::FlashHash.new
    flash[:notice] = 'Signed in'

    payload = Boot::User.new(user, root_url: 'https://example.com', flash: flash).payload

    refute_includes payload.to_json, user.secret_token
    assert_equal user.id, payload[:current_user_id]
    assert_equal 'https://example.com', payload[:root_url]
    assert_equal({ 'notice' => 'Signed in' }, payload[:flash])
    assert_equal({}, payload[:pending_identity])
    assert_equal true, payload[:groups_loaded]
    assert_includes payload.fetch(:groups).pluck(:id), groups(:group).id
    assert_equal [user.id], payload.fetch(:memberships).pluck(:user_id).uniq
    assert_equal [user.id], payload.fetch(:users).pluck(:id)
  end

  test "boot includes guest group context without unrelated groups or memberships" do
    user = users(:guest_normal)
    payload = Boot::User.new(user, root_url: 'https://example.com').payload

    assert_includes payload.fetch(:groups).pluck(:id), groups(:group).id
    refute_includes payload.fetch(:groups).pluck(:id), groups(:alien_group).id
    refute_includes payload.fetch(:groups).pluck(:id), groups(:parent_join_subgroup).id
    assert payload.fetch(:memberships, []).all? { |membership| membership[:user_id] == user.id }
  end

  test "signed out bootstrap retains pending sign in details" do
    token = LoginToken.create!(user: users(:user))
    pending = Pending::TokenSerializer.new(token, root: false).as_json
    payload = Boot::User.new(LoggedOutUser.new, root_url: 'https://example.com', identity: pending).payload

    assert_equal false, payload.dig(:users, 0, :has_passkey)
    assert_equal pending, payload[:pending_identity]
    assert_nil payload[:current_user_id]
    refute payload.key?(:groups_loaded)
    refute payload.key?(:groups)
  end
end
