require "test_helper"
require_relative "ability_contract_helper"

# Server answers for editing, resending and removing memberships, checked
# against the client's MembershipAbility by
# vue/tests/component/membership_ability_contract.test.js.
class MembershipAbilityContractTest < ActiveSupport::TestCase
  include AbilityContractHelper

  ACTIONS = %i[update resend destroy].freeze
  MEMBERSHIP_ROLES = (ROLES + %i[member]).freeze

  test "writes the membership ability contract for the client" do
    cases = travel_to(CONTRACT_TIME) do
      group = groups(:group)
      MEMBERSHIP_ROLES.flat_map do |role|
        user = users(role)
        memberships(user, group).map do |kind, membership|
          {
            name: "#{role} #{kind}",
            roles: {user_id: user.id, signed_in: user.is_logged_in?, email_verified: user.email_verified?,
                    server_admin: user.is_admin?, group_admin: group.admins.exists?(user.id)},
            membership: raw(membership, %i[user_id inviter_id accepted_at admin]),
            expected: answers(user, membership, ACTIONS)
          }
        end
      end
    end
    write_ability_contract("membership_abilities", cases)
  end

  private

  def memberships(user, group)
    found = {
      "own membership" => group.memberships.active.find_by(user_id: user.id),
      "another member" => group.memberships.active.where.not(user_id: user.id).accepted.order(:id).first!,
      "invitation they sent" => invitation(group, inviter: user),
      "invitation someone else sent" => invitation(group, inviter: group.admins.order(:id).first!)
    }
    found.compact
  end

  def invitation(group, inviter:)
    invitee = User.create!(email: "invitee-#{SecureRandom.hex(4)}@example.com", email_verified: false)
    Membership.create!(group: group, user: invitee, inviter: inviter, accepted_at: nil)
  end
end
