When /^I choose to edit the discussion description$/ do
  click_link("edit_description")
end

When /^I fill in and submit the discussion description form$/ do
  @description_text = "This discussion is interesting"
  fill_in "description-input", :with  => @description_text
  click_on("add-description-submit")
end

Given /^I am a member of this group$/ do
  @group.add_member! @user
end

Then /^I should see the description change$/ do
  page.should have_content(@description_text)
end

Then /^I should see a record of my change in the discussion feed$/ do
  find('#history-list').should have_content(@description_text)
end

Then /^I should not see a link to edit the description$/ do
  page.should_not have_css("edit_description")
end

Given /^I am not a member of this group$/ do
end

Given /^there is a discussion in a group$/ do
  @group = FactoryGirl.create :group
  @discussion = FactoryGirl.create :discussion, :group => @group
end