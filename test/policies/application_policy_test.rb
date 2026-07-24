require "test_helper"

class ApplicationPolicyTest < ActiveSupport::TestCase
  setup do
    @context = AuthorizationContext.new(
      user: users(:user),
      authentication: :session
    )
    @policy = ApplicationPolicy.new(@context, Object.new)
  end

  test "denies every conventional action by default" do
    refute @policy.index?
    refute @policy.show?
    refute @policy.create?
    refute @policy.new?
    refute @policy.update?
    refute @policy.edit?
    refute @policy.destroy?
  end

  test "scope raises until a policy implements it" do
    error = assert_raises(Pundit::NotDefinedError) do
      ApplicationPolicy::Scope.new(@context, Object).resolve
    end

    assert_match "must implement #resolve", error.message
  end

  test "requires an authorization context" do
    assert_raises(Pundit::NotAuthorizedError) do
      ApplicationPolicy.new(nil, Object.new)
    end
  end
end
