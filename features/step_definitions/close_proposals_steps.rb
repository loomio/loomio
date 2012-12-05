Given /^I am an admin of the group$/ do
  @group.add_admin! @user
end

Given /^the discussion has an open proposal$/ do
  @motion = FactoryGirl.create :motion, :discussion => @discussion
end

When /^I click the 'Close proposal' button$/ do
  click_on 'Close proposal'
end

When /^I confirm the action$/ do
  find('#confirm-action').click()
end

Then /^I should see the proposal in the list of previous proposals$/ do
  find('#previous-proposals').should have_content(@motion.name)
end

Given /^there is a discussion in a group$/ do
  @user =FactoryGirl.create :user
  @group = FactoryGirl.create :group
  @discussion = FactoryGirl.create :discussion, :group => @group
end

Then /^I should not see a link to close the proposal$/ do
  page.should_not have_content("Close proposal")
end