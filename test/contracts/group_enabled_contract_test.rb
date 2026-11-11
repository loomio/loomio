require "test_helper"
require_relative "ability_contract_helper"

# Server answers for whether a group is enabled, with the group payload each
# viewer receives. vue/tests/component/group_enabled_contract.test.js imports
# each payload into the record store and checks GroupModel#isEnabled.
class GroupEnabledContractTest < ActiveSupport::TestCase
  include AbilityContractHelper

  EXPIRY = {"no expiry" => nil, "expired" => -1.day, "expiring" => 1.day}.freeze
  VIEWERS = {"member" => :user, "visitor" => nil}.freeze

  test "writes the group enabled contract for the client" do
    cases = travel_to(CONTRACT_TIME) do
      parent = groups(:public_group)
      subgroup = Group.create!(name: "Contract subgroup", parent: parent, group_privacy: "open", handle: "publicgroup-contract")
      member = users(:user)
      [parent, subgroup].each { |group| group.add_member!(member) }

      subscription_cases(parent, subgroup) + missing_subscription_cases(parent) + discarded_cases(parent)
    end
    write_ability_contract("group_enabled", cases)
  end

  private

  def subscription_cases(parent, subgroup)
    subscription = Subscription.create!(plan: "pro", state: "active")
    parent.update!(subscription: subscription)
    Subscription::STATES.product(EXPIRY.keys, [parent, subgroup]).flat_map do |state, expiry, group|
      offset = EXPIRY.fetch(expiry)
      subscription.update!(state: state, expires_at: offset && Time.current + offset)
      viewer_cases("#{state} #{expiry} #{group.parent_id ? 'subgroup' : 'group'}", group)
    end
  end

  def missing_subscription_cases(parent)
    parent.update!(subscription: nil)
    viewer_cases("no subscription", parent)
  end

  def discarded_cases(parent)
    parent.update_columns(discarded_at: 1.hour.ago)
    viewer_cases("discarded", parent).tap { parent.update_columns(discarded_at: nil) }
  end

  def viewer_cases(label, group)
    group = Group.find(group.id)
    VIEWERS.map do |viewer, fixture|
      user = fixture ? users(fixture) : LoggedOutUser.new
      user_id = user.is_logged_in? ? user.id : nil
      json = ActiveModel::ArraySerializer.new([group], each_serializer: GroupSerializer, root: :groups,
        scope: {cache: RecordCache.for_collection([group], user_id, []), current_user_id: user_id, exclude_types: []}).as_json
      {
        name: "#{viewer} #{label}",
        roles: {user_id: user_id, signed_in: user.is_logged_in?, email_verified: !!user_id, server_admin: false},
        payload: JSON.parse(json.to_json),
        group_id: group.id,
        expected: {enabled: group.enabled?}
      }
    end
  end
end
