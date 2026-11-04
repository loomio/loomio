require "test_helper"
require_relative "../../support/access_volume_matrix"

class Ability::IdentityTest < ActiveSupport::TestCase
  test "identity access belongs to its account across the reusable role matrix" do
    owner = users(:member_normal)
    identity = Identity.create!(identity_type: "oauth", uid: "identity-permissions", user: owner)
    actors = AccessVolumeMatrix::ROLES.map { |role| users(role) } + [users(:server_admin), LoggedOutUser.new]

    actors.each do |actor|
      %i[show destroy].each do |action|
        assert_equal actor.id == owner.id, actor.can?(action, identity), "#{actor.id}: #{action}"
      end
    end
  end

  test "a pending identity grants no account access" do
    identity = Identity.create!(identity_type: "oauth", uid: "pending-identity-permissions")

    [users(:member_normal), users(:admin), users(:server_admin), LoggedOutUser.new].each do |actor|
      assert_not actor.can?(:show, identity)
      assert_not actor.can?(:destroy, identity)
    end
  end
end
