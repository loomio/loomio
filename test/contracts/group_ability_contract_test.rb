require "test_helper"
require_relative "ability_contract_helper"

# Server answers for viewing, managing and joining groups, checked against the
# client's GroupAbility by vue/tests/component/group_ability_contract.test.js.
class GroupAbilityContractTest < ActiveSupport::TestCase
  include AbilityContractHelper

  ACTIONS = %i[show see_private_content update destroy set_volume add_members add_guests
               manage_membership_requests notify add_subgroup join].freeze
  GROUPS = %i[group subgroup parent_join_subgroup].freeze
  GROUP_ROLES = (ROLES + %i[subgroup_user]).freeze
  GROUP_FIELDS = %i[parent_id discarded_at is_visible_to_public is_visible_to_parent_members membership_granted_upon
                    members_can_add_members members_can_add_guests members_can_announce members_can_create_subgroups].freeze
  SETTINGS = {
    "permissive" => {members_can_add_members: true, members_can_add_guests: true, members_can_announce: true, members_can_create_subgroups: true},
    "restrictive" => {members_can_add_members: false, members_can_add_guests: false, members_can_announce: false, members_can_create_subgroups: false}
  }.freeze

  test "writes the group ability contract for the client" do
    cases = travel_to(CONTRACT_TIME) do
      GROUPS.product(%w[open closed secret], SETTINGS.keys).flat_map do |name, privacy, setting|
        cases_for(name, privacy, setting)
      end
    end
    write_ability_contract("group_abilities", cases)
  end

  private

  def cases_for(name, privacy, setting)
    group = Group.find(groups(name).id)
    group.assign_attributes(SETTINGS.fetch(setting))
    group.group_privacy = privacy
    group.save!(validate: false)
    group.reload
    parent = group.parent_or_self

    GROUP_ROLES.map do |role|
      user = users(role)
      request = MembershipRequest.new(group: group, requestor: user)
      {
        name: "#{role} #{name} #{privacy} #{setting}",
        roles: {
          user_id: user.id, signed_in: user.is_logged_in?, email_verified: user.email_verified?, server_admin: user.is_admin?,
          group_admin: group.admins.exists?(user.id), group_member: group.members.exists?(user.id),
          parent_admin: parent.admins.exists?(user.id), parent_member: parent.members.exists?(user.id)
        },
        group: raw(group, GROUP_FIELDS).merge("group_privacy" => group.group_privacy, "enabled" => group.enabled?),
        expected: answers(user, group, ACTIONS).merge(request_membership: Ability::Base.new(user).can?(:create, request))
      }
    end
  end
end
