require "test_helper"

class AuthorizationContextTest < ActiveSupport::TestCase
  test "delegates user predicates without hiding authentication mechanism" do
    user = users(:user)
    context = AuthorizationContext.new(user:, authentication: :b2_api_key)

    assert_equal user.id, context.id
    assert context.api_key?
    refute context.signed_out?
  end

  test "represents signed-out access explicitly" do
    context = AuthorizationContext.new(
      user: LoggedOutUser.new,
      authentication: :signed_out
    )

    assert context.signed_out?
    refute context.api_key?
  end
end
