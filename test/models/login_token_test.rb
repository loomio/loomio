require 'test_helper'

class LoginTokenTest < ActiveSupport::TestCase
  test "has a token" do
    token = LoginToken.new(user: users(:normal_user))
    assert token.token.present?
  end

  test "has a code" do
    token = LoginToken.new(user: users(:normal_user))
    assert token.code.present?
  end

  test "is useable by default" do
    token = LoginToken.create!(user: users(:normal_user))
    assert token.useable?
  end

  test "is not useable if it has been used before" do
    token = LoginToken.create!(user: users(:normal_user))
    token.update!(used: true)
    assert_not token.useable?
  end

  test "is not useable if it is old" do
    token = LoginToken.create!(user: users(:normal_user))
    token.update!(created_at: 25.hours.ago)
    assert_not token.useable?
  end
end
