require 'test_helper'

class BootUserTest < ActiveSupport::TestCase
  test "signed in users receive a channel token" do
    user = users(:user)

    payload = Boot::User.new(user, root_url: 'https://example.com').payload

    assert_equal user.secret_token, payload[:channel_token]
  end

  test "signed out users report that they have no passkey" do
    payload = Boot::User.new(LoggedOutUser.new, root_url: 'https://example.com').payload

    assert_equal false, payload.dig(:users, 0, :has_passkey)
  end
end
