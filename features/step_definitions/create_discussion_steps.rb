Given /^I am viewing a discussion titled "(.*?)" in "(.*?)"$/ do |disc_title, group_name|
  @discussion = FactoryGirl.create :discussion,
               :title => disc_title, :group => Group.find_by_name(group_name)
  visit discussion_path(@discussion)
end

When /^I choose to create a discussion$/ do
  click_link 'Start a discussion'
end

When /^I select the group from the groups dropdown$/ do
  select @group.name, from: 'discussion_group_id'
end

When /^I fill in the discussion details and submit the form$/ do
  fill_in 'discussion_title', with: 'New discussion Test'
  fill_in 'discussion_description', with: 'Description of test discussion'
  click_on 'discussion-submit'
end

Then /^a discussion should be created$/ do
  Discussion.where(:title => "New discussion Test").should exist
end

Given /^"(.*?)" is a member of the group$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^"(.*?)" has chosen to be emailed about new discussions and decisions for the group$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^"(.*?)" has chosen not to be emailed about new discussions and decisions for the group$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^"(.*?)" should be emailed about the new discussion$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^"(.*?)" should not be emailed about the new discussion$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end
