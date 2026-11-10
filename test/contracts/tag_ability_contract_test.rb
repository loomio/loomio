require "test_helper"
require_relative "ability_contract_helper"

# Server answers for creating tags inline, checked against the client's
# TagAbility by vue/tests/component/tag_ability_contract.test.js.
class TagAbilityContractTest < ActiveSupport::TestCase
  include AbilityContractHelper

  test "writes the tag ability contract for the client" do
    cases = travel_to(CONTRACT_TIME) do
      %i[group subgroup].product([true, false]).flat_map do |name, members_can_create|
        group = Group.find(groups(name).id)
        group.update_columns(members_can_create_tags: members_can_create)
        (ROLES + %i[subgroup_user]).map do |role|
          user = users(role)
          {
            name: "#{role} #{name}#{' members-create' if members_can_create}",
            roles: {user_id: user.id, signed_in: user.is_logged_in?, email_verified: user.email_verified?, server_admin: user.is_admin?,
                    group_admin: group.admins_include?(user), group_member: group.members_include?(user),
                    parent_admin: group.parent_or_self.admins_include?(user)},
            group: {members_can_create_tags: members_can_create},
            expected: {create: TagService.can_create_tag?(group, user)}
          }
        end
      end
    end
    write_ability_contract("tag_abilities", cases)
  end
end
