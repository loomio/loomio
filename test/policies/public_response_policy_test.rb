require "test_helper"

class PublicResponsePolicyTest < ActiveSupport::TestCase
  setup do
    @context = AuthorizationContext.new(
      user: LoggedOutUser.new,
      authentication: :signed_out
    )
  end

  test "allows only named reviewed public responses" do
    assert PublicResponsePolicy.new(@context, :boot_version).show?
    refute PublicResponsePolicy.new(@context, :unreviewed_response).show?
  end
end
