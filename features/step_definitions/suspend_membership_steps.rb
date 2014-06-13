Given(/^there is a group member causing a ruckus$/) do
  @bad_user = FactoryGirl.create(:user)
  @group.add_member!(@bad_user)
  @subgroup = FactoryGirl.create(:group, parent: @group)
  @subgroup.add_member!(@bad_user)
end

When(/^I suspend their group membership$/) do
  MembershipService.suspend_membership!(membership: @group.membership_for(@bad_user))
end

Then(/^the suspended member loses their membership privileges$/) do
  @group.reload
  @group.membership_for(@bad_user).should be_is_suspended
  @subgroup.membership_for(@bad_user).should be_is_suspended
end
