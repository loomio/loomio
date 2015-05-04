Given(/^I am a signed in group admin$/) do
  @group = FactoryGirl.create :group
  @user = FactoryGirl.create :user
  @group.add_admin! @user
  login @user
end

When(/^I click 'More'$/) do
  visit group_path(@group)
  click_on I18n.t(:"more")
end

Then(/^I should see the memberships index$/) do
  page.should have_css('body.memberships.index')
  expect(current_path).to eq group_memberships_path(@group)
end

Given(/^there is another group member$/) do
  @another_user = FactoryGirl.create :user
  @group.add_member! @another_user
end


When(/^click 'Make coordinator' on the member$/) do
  click_on 'Make coordinator'
end

Then(/^the member should be a group admin$/) do
  @group.admins.reload.should include @another_user
end

Given(/^there is another group admin$/) do
  @another_user = FactoryGirl.create :user
  @group.add_admin! @another_user
end

When(/^click 'Remove coordinator' on the member$/) do
  within("table.memberships tbody tr#membership-for-user-#{@another_user.id}") do
    click_on 'Remove coordinator'
  end
end

Then(/^the member should no longer be a group admin$/) do
  @group.admins.should_not include @another_user
end

Then(/^the member should no longer belong to the group$/) do
  @group.members.should_not include @another_user
end

When(/^click 'Remove' on the member$/) do
  within("table.memberships tbody tr#membership-for-user-#{@another_user.id}") do
    click_on 'Remove'
  end
end
