Given(/^I am a guest$/) do
  @user = FactoryGirl.build(:user, name: "Herby Hancock", email: "herb@home.com")
end

Given(/^I am a logged out user$/) do
  @user = FactoryGirl.create(:user, name: "Herby Hancock", email: "herb@home.com")
end

Given(/^I am on the home page of the website$/) do
  visit '/'
end

When(/^I go to start a new group from the navbar$/) do
  find(".group-links a.new-group").click
end

When(/^I go to start a new group$/) do
  visit new_group_request_path
end

When(/^I fill in and submit the form$/) do
  @group_name = "Herby's Erbs"
  fill_in :group_request_admin_name, with: @user.name
  fill_in :group_request_admin_email, with: @user.email
  fill_in :group_request_name, with: @group_name
  click_on 'sign-up-submit'
end

When(/^I click the invitation link$/) do
  link = links_in_email(current_email)[2]
  request_uri = URI::parse(link).request_uri
  visit request_uri
  # click_email_link_matching(invitation_url(@group_request.token))
end

When(/^I complete and submit the form$/) do
  @group_name = "Hermans Herbs"
  fill_in :group_name, with: @group_name
  fill_in :group_description, with: "A collection of the finest herbs"
  click_on 'Start group!'
end

When(/^I sign in to Loomio$/) do
  find('.existing-user').click()
  fill_in :user_email, with:  @user.email
  fill_in :user_password, with: @user.password
  find('#sign-in-btn').click()
end

When(/^I setup the group$/) do
  fill_in :group_description, with: "A collection of the finest herbs"
  click_on 'Take me to my group!'
end

When(/^I click start group without filling in any fields$/) do
 click_on "sign-up-submit"
end

Then(/^I should see the thank you page$/) do
  page.should have_css("body.group_requests.confirmation")
end

Then (/^I should recieve an email with an invitation link$/) do
  open_email(@user.email)
  @invitation = Invitation.find_by_recipient_email(@user.email)
  current_email.should have_content(invitation_path(@invitation))
end

Then(/^I should be taken to the new group$/) do
  page.should have_css("body.groups.show")
end

Then(/^I should see the start group form with errors$/) do
  page.should have_content 'can\'t be blank'
end

Then(/^the example content should be created$/) do
  @group = Group.where(name: @group_name).first
  @group.discussions.first.title.should == I18n.t('example_discussion.title')
  @group.motions.first.name.should == I18n.t('example_motion.name')
end
