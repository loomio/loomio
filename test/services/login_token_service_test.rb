require 'test_helper'

class LoginTokenServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @uri = URI::parse "http://#{ENV['CANONICAL_HOST']}/explore"
    @bad_uri = URI::parse "http://badhost.biz/explore"
  end

  test "creates a new login token" do
    assert_difference '@user.login_tokens.count', 1 do
      LoginTokenService.create(actor: @user, uri: @uri)
    end
  end

  test "sends an email to the user" do
    assert_difference 'ActionMailer::Base.deliveries.count', 1 do
      LoginTokenService.create(actor: @user, uri: @uri)
    end
  end

  test "does nothing if the actor is not logged in" do
    ActionMailer::Base.deliveries.clear
    LoginTokenService.create(actor: LoggedOutUser.new, uri: @uri)
    assert_equal 0, ActionMailer::Base.deliveries.count
  end

  test "stores a redirect uri" do
    LoginTokenService.create(actor: @user, uri: @uri)
    assert_equal '/explore', LoginToken.last.redirect
  end

  test "does not store a redirect uri if the host is different" do
    LoginTokenService.create(actor: @user, uri: @bad_uri)
    assert_nil LoginToken.last.redirect
  end
end
