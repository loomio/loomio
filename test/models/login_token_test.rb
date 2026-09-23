require 'test_helper'

class LoginTokenTest < ActiveSupport::TestCase
  test "has a token" do
    token = LoginToken.new(user: users(:user))
    assert token.token.present?
  end

  test "has a code" do
    token = LoginToken.new(user: users(:user))
    assert token.code.present?
  end

  test "is useable by default" do
    token = LoginToken.create!(user: users(:user))
    assert token.useable?
  end

  test "is not useable if it has been used before" do
    token = LoginToken.create!(user: users(:user))
    token.update!(used: true)
    assert_not token.useable?
  end

  test "is not useable after too many failed code attempts" do
    token = LoginToken.create!(user: users(:user), failed_attempts: LoginToken::MAX_FAILED_CODE_ATTEMPTS)

    assert_not token.useable?
  end

  test "records failed code attempts and burns token at the limit" do
    token = LoginToken.create!(user: users(:user), failed_attempts: LoginToken::MAX_FAILED_CODE_ATTEMPTS - 1)

    token.record_failed_code_attempt!

    assert_equal LoginToken::MAX_FAILED_CODE_ATTEMPTS, token.failed_attempts
    assert token.used
  end

  test "is not useable if it is old" do
    token = LoginToken.create!(user: users(:user))
    token.update!(created_at: 25.hours.ago)
    assert_not token.useable?
  end

  test "is useable for 24 hours by default" do
    token = LoginToken.create!(user: users(:user))
    token.update!(created_at: 23.hours.ago)

    assert_equal token.created_at + 24.hours, token.expires_at
    assert token.useable?
  end
end
