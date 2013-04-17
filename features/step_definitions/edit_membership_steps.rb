Given(/^I am a signed in group admin$/) do
  @group = FactoryGirl.create :group
  @user = FactoryGirl.create :user
  @group.add_admin! @user
  login @user.email, @user.password
end

When(/^I view click edit memberships from the group page$/) do
  visit group_path(@group)
  click_on '.memberships-dropdown'
  clikc_on 'Edit memberships'
end

Then(/^I should see the edit memberships page for the group$/) do
  page.should have_content 'Edit Memberships'
  current_path.should == group_memberships_path(@group)
end
