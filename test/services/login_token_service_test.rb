require 'test_helper'

class LoginTokenServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @uri = URI::parse "http://#{ENV['CANONICAL_HOST']}/explore"
    @bad_uri = URI::parse "http://badhost.biz/explore"
  end

  test "creates a new login token" do
    token = nil
    assert_difference '@user.login_tokens.count', 1 do
      token = LoginTokenService.create(actor: @user, uri: @uri)
    end
    assert_predicate token, :persisted?
    assert_equal @user, token.user
    assert_equal '/explore', token.redirect
    assert_equal '/explore', token.reload.redirect
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

  test "does not store a redirect uri if the host is different" do
    LoginTokenService.create(actor: @user, uri: @bad_uri)
    assert_nil LoginToken.last.redirect
  end
end
