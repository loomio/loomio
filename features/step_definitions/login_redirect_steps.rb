Given(/^I have no groups$/) do
  @user = FactoryGirl.create(:user)
end

When(/^I login$/) do
  visit new_user_session_path
  fill_in 'Email', with: @user.email
  fill_in 'Password', with: 'complex_password'
  click_on 'Log in'
end

Then(/^I should arrive on the explore page$/) do
  current_path.should eq '/explore'
end

Given(/^I have 1 group$/) do
  @user = FactoryGirl.create(:user)
  @group = FactoryGirl.create(:group)
  @group.add_member!(@user)
end

Then(/^I should arrive on my group page$/) do
  current_path.should eq group_path(@group)
end

Given(/^I have more than 1 group$/) do
  @user = FactoryGirl.create(:user)
  2.times do
    @group = FactoryGirl.create(:group)
    @group.add_member!(@user)
  end
end

Then(/^I should arrive on the dashboard page$/) do
  current_path.should eq '/dashboard'
end
