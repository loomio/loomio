Given(/^I am a signed in group admin$/) do
  @group = FactoryGirl.create :group
  @user = FactoryGirl.create :user
  @group.add_admin! @user
  login @user
end

When(/^I view click edit memberships from the group page$/) do
  visit group_path(@group)
  click_on 'Edit memberships'
end

Then(/^I should see the edit memberships page for the group$/) do
  page.should have_css('body.memberships.index')
  current_path.should == group_memberships_path(@group)
end

Then(/^I should see the edit memberships page$/) do
  page.should have_css('body.memberships.index')
end

Given(/^there is another group member$/) do
  @another_user = FactoryGirl.create :user
  @group.add_member! @another_user
end


When(/^click 'Make admin' on the member$/) do
  click_on 'Make admin'
end

Then(/^the member should be a group admin$/) do
  @group.admins.should include @another_user
end

Given(/^there is another group admin$/) do
  @another_user = FactoryGirl.create :user
  @group.add_admin! @another_user
end

When(/^click 'Remove admin' on the member$/) do
  within("table.memberships tbody tr#membership-for-user-#{@another_user.id}") do
    click_on 'Remove admin'
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
