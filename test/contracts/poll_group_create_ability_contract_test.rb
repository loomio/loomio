require "test_helper"
require_relative "ability_contract_helper"

class PollGroupCreateAbilityContractTest < ActiveSupport::TestCase
  include AbilityContractHelper

  test "writes standalone poll creation permissions for each group and role" do
    cases = travel_to(CONTRACT_TIME) do
      %w[open closed secret].product([true, false], %w[active on_hold]).flat_map do |privacy, members_can_raise_motions, state|
        group = groups(:group)
        Subscription.for!(group).update_columns(state: state)
        group.update!(group_privacy: privacy, members_can_raise_motions: members_can_raise_motions)
        ROLES.map do |role|
          user = users(role)
          poll = PollService.build(params: {group_id: group.id, title: "Standalone poll", poll_type: "proposal"}, actor: user)
          {
            name: "#{role} #{privacy} #{members_can_raise_motions} #{state}",
            roles: role_facts(user, poll.topic),
            group: {enabled: group.enabled?, members_can_raise_motions: members_can_raise_motions},
            expected: {create: user.can?(:create, poll)}
          }
        end
      end
    end
    write_ability_contract("poll_group_create_abilities", cases)
  end
end
