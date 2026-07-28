require 'test_helper'

class BootUserTest < ActiveSupport::TestCase
  test "restricted users do not receive a channel token" do
    user = users(:user)
    user.restricted = true

    payload = Boot::User.new(user, root_url: 'https://example.com').payload

    assert_not payload.key?(:channel_token)
  end

  test "signed in users receive a channel token" do
    user = users(:user)

    payload = Boot::User.new(user, root_url: 'https://example.com').payload

    assert_equal user.secret_token, payload[:channel_token]
  end
end
