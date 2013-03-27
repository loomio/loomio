When /^I choose to edit the discussion description$/ do
  click_link("edit_description")
end

When /^I fill in and submit the discussion description form$/ do
  @description_text = "This discussion is interesting"
  fill_in "description-input", :with  => @description_text
  click_on("add-description-submit")
end

When /^I enable markdown for the discussion description$/ do
  find("#discussion-markdown-dropdown-link").click
  # click_on 'disccussion-markdown-dropdown-link'
  click_on 'enable-markdown-link'
end

Then /^I should see the description change$/ do
  find('#discussion-context').should have_content(@description_text)
end

Then /^I should see a record of my change in the discussion feed$/ do
  find('#activity-feed').should have_content('changed the discussion description')
end

Then /^I should not see a link to edit the description$/ do
  page.should_not have_css("edit_description")
end

Given /^I am not a member of the group$/ do
end

Given /^there is a discussion in a group$/ do
  @group = FactoryGirl.create :group
  @discussion = FactoryGirl.create :discussion, :group => @group
end

Given /^my global markdown preference is 'disabled'$/ do
  step "I don't prefer markdown"
end

When /^I see discussion markdown is disabled$/ do
  find("#discussion-markdown-dropdown").should have_css('.markdown-off')
end

When /^I see discussion markdown is enabled$/ do
  find("#discussion-markdown-dropdown").should have_css('.markdown-on')
end

Then /^the discussion desription should render markdown$/ do
  find('.description-body').should_not have_content("*markdown*")
end

Then /^my global markdown preference should still be 'disabled'$/ do
  @user.uses_markdown.should == false
end
