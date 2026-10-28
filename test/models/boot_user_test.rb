require 'test_helper'

class BootUserTest < ActiveSupport::TestCase
  test "signed in users receive a channel token" do
    user = users(:user)
    flash = ActionDispatch::Flash::FlashHash.new
    flash[:notice] = 'Signed in'

    payload = Boot::User.new(user, root_url: 'https://example.com', flash: flash).payload

    assert_equal user.secret_token, payload[:channel_token]
    assert_equal user.id, payload[:current_user_id]
    assert_equal 'https://example.com', payload[:root_url]
    assert_equal({ 'notice' => 'Signed in' }, payload[:flash])
    assert_equal({}, payload[:pending_identity])
  end

  test "signed out bootstrap retains pending sign in details without an authenticated channel" do
    token = LoginToken.create!(user: users(:user))
    pending = Pending::TokenSerializer.new(token, root: false).as_json
    payload = Boot::User.new(LoggedOutUser.new, root_url: 'https://example.com', identity: pending).payload

    assert_equal false, payload.dig(:users, 0, :has_passkey)
    assert_equal pending, payload[:pending_identity]
    assert_nil payload[:current_user_id]
    assert_nil payload[:channel_token]
  end
end
