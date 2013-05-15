Given /^I am in one of the same groups as another user$/ do
  @other_user = FactoryGirl.create(:user)
  @group = FactoryGirl.create(:group)
  @group.add_member!(@other_user)
  @group.add_member!(@user)
end

Given /^I am not in any of the same groups as another user$/ do
  @other_user = FactoryGirl.create(:user)
  @group = FactoryGirl.create(:group)
  @group.add_member!(@user)
end

Given /^another user exists$/ do
  @other_user = FactoryGirl.create(:user)
end

When /^I visit the other user's profile page$/ do
  visit(user_path(@other_user))
end

Then /^I should see the other user's profile information$/ do
  page.should have_css(".users.show")
  page.should have_content(@other_user.email)
end

Then /^I should not see the other user's profile information$/ do
  page.should_not have_css(".users.show")
  page.should_not have_content(@other_user.email)
end
