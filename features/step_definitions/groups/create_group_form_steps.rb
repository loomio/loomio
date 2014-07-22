Given(/^I am on the create a group page$/) do
  visit new_group_path
end

When(/^a group is made visible, join on request$/) do
  click_on 'Next'
  choose 'group_visible_to_public'
  choose 'group_membership_granted_upon_request'
end

Then(/^discussion privacy is set to public, and other options are disabled$/) do
  find('#group_discussion_privacy_options_public_only').should be_checked
  #capybara sucks for this stuff
  #find('#group_discussion_privacy_options_public_or_private')[:disabled].should == 'disabled'
  #find('#group_discussion_privacy_options_private_only')['disabled'].should == 'disabled'
end

When(/^a group is made visible, join on approval$/) do
  choose 'group_visible_to_public'
  choose 'group_membership_granted_upon_approval'
end

Then(/^all 3 discussion privacy options are available$/) do
  find('#group_discussion_privacy_options_public_only')['disabled'].should be_nil
  find('#group_discussion_privacy_options_public_or_private')['disabled'].should be_nil
  find('#group_discussion_privacy_options_private_only')['disabled'].should be_nil
end

When(/^a group is made hidden$/) do
  choose 'group_visible_to_members'
end

Then(/^the form selects invitation only, and disables other join options$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^who can add members shows up$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^private discussions only is selected, other privacy options disabled$/) do
  pending # express the regexp above with the code you wish you had
end
