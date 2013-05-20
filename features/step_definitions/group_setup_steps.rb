Given /^I visit the group setup wizard for that group$/ do
  visit setup_group_path(@group.id)
end

Given /^the users time-zone has been set$/ do
  @user.update_attribute(:time_zone, "Auckland")
end

Given(/^I fill in the form upto the invites tab$/) do
  find('#start').click()
  step 'I fill in the group panel'
  step "I click the \"next\" button"
  step 'I fill in the discussion panel'
  step "I click the \"next\" button"
end

When(/^I fill in the group name$/) do
  @group_name = "Fantastic Spinners"
  fill_in 'Group name', with: @group_name
end

When(/^a group is already setup$/) do
  @group.setup_completed_at = Time.now
  @group.save!
end

When(/^I fill in a list of valid and invalid emails$/) do
  fill_in "invitees", with: "peter@post.com, der_rick@more.org, 'susan scrimsure' <sus@scrimmy.com>, am$%^87766, .com.com"
end

When /^I click Goto group$/ do
  click_on 'Goto group'
end

When /^I click the "(.*?)" button$/ do |id|
  find("##{id}").click
end

When /^I fill in the group panel$/ do
  fill_in 'group_setup_group_description', with: "A discription of my group"
end

When /^I fill in the discussion panel$/ do
  fill_in 'Discussion title', with: "My discussion title"
  fill_in 'group_setup_discussion_description', with: "A discription of my discussion"
end

When /^I fill in the invites panel$/ do
  fill_in 'invitees', with: "peanut@butter.co.nz, jam@toastie.com"
end

Then(/^the group should be saved$/) do
  group_setup = GroupSetup.find_by_group_id(@group.id)
  group_setup.group_name.should == @group_name
end

Then /^I should see the setup group tab$/ do
  find('.tab-content').should have_css('#group-tab.active')
end

Then /^I should see the setup discussion tab$/ do
  find('.tab-content').should have_css('#discussion-tab.active')
end

Then /^I should see the setup invites tab$/ do
  find('.tab-content').should have_css('#invite-tab.active')
end

When /^I am on the final tab$/ do
  find('ul.nav-tabs li:last a').click()
end

Then /^the group_setup should be created$/ do
  @group_setup = GroupSetup.find_by_group_id(@group.id)
end

Then /^the group should have a discussion$/ do
  @group_setup.group.discussions.count.should == 1
end

Then /^I should see the group page$/ do
  find('.group-title').should have_content(@group.name)
end

Then(/^I should see my time zone set in the timezone select$/) do
  find('#group_setup_close_at_time_zone').value.should ==  "Auckland"
end

Then /^I should see the finished page$/ do
  page.should have_content('Finished!')
end

Then(/^I should be told that I dont have permission to set up this group$/) do
  page.should have_content(I18n.t('error.not_permitted_to_setup_group'))
end

Then(/^I should see a flash message displaying number of valid emails$/) do
  find('.alert').should have_content('3 invitation(s) sent')
end

Then(/^the date the group was setup is stored$/) do
  @group_setup.group.setup_completed_at.should_not be_nil
end

Then(/^I should be told that the group has already been setup$/) do
  page.should have_content(I18n.t('error.group_already_setup'))
end

Then(/^I should see a list of the valid emails$/) do
  page.should have_content "peter@post.com"
  page.should have_content "der_rick@more.org"
  page.should have_content "sus@scrimmy.com"
end

Then /^I should see the group setup wizard$/ do
  page.should have_content('Set up your group')
end

Then /^invitations should be sent out to each recipient$/ do
  ["peanut@butter.co.nz", "jam@toastie.com"].each do |email_address|
    open_email(email_address)
    current_email.should have_content(@group_setup.message_body)
    current_email.should have_content(@group_setup.motion_title)
    current_email.should have_content(@group_setup.motion_description)
    current_email.should have_content(@group_setup.group_name)
  end
end