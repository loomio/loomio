Given(/^There are default group covers available$/) do
  FactoryGirl.create(:default_group_cover)
end

Given(/^I am a logged out user$/) do
  @user = FactoryGirl.create(:user, name: "Herby Hancock", email: "herb@home.com")
end

Given(/^I am on the home page of the website$/) do
  visit '/'
end

When(/^I go to start a new group from the navbar$/) do
  find('.groups-dropdown-btn').click
  find(".group-links a.new-group").click
end

When(/^I go to start a new group$/) do
  visit start_group_path
end


When(/^I click the invitation link$/) do
  link = links_in_email(current_email)[2]
  request_uri = URI::parse(link).request_uri
  visit request_uri
  # click_email_link_matching(invitation_url(@group_request.token))
end

When(/^I sign in to Loomio$/) do
  find('.existing-user').click()
  fill_in :user_email, with:  @user.email
  fill_in :user_password, with: @user.password
  find('#sign-in-btn').click()
end

When(/^I click start group without filling in any fields$/) do
 click_on "sign-up-submit"
end

Then(/^I should see the thank you page$/) do
  page.should have_css(".start-group__success")
end

Then (/^I should receive an email with an invitation link$/) do
  open_email('hank.schrader@cops.com')
  @invitation = Invitation.find_by_recipient_email('hank.schrader@cops.com')
  current_email.should have_content(invitation_path(@invitation))
end

Then(/^I should be taken to the new group$/) do
  page.should have_css("body.groups.show")
end

Then(/^I should be the creator of the group$/) do
  @group = Group.where(name: @group_name).first
  @group.creator.should == @user
end

Then(/^the group should be non referral$/) do
  @group.is_referral.should == false
end

Then(/^I should see the start group form with errors$/) do
  page.should have_content 'Some information is missing or incorrect'
  page.should have_content 'Name is required'
  page.should have_content 'Not a valid email address'
  page.should have_content 'Group name is required'
end

Then(/^the example content should be present$/) do
  @group = Group.where(name: @group_name).first
  expect(@group.discussions.first.title).to eq I18n.t('introduction_thread.title', group_name: @group_name)
  expect(@group.motions.first.name).to eq I18n.t('first_proposal.name')
end

When(/^I click 'Try Loomio' from the front page$/) do
  visit '/'
  click_on :'try-it-main'
end

When(/^I fill in the start group form$/) do
  @group_name = 'Hank\'s Hankeys and Handkerchiefs'
  fill_in :name, with: 'Hank Schrader'
  fill_in :email, with: 'hank.schrader@cops.com'
  fill_in :group_name, with: @group_name
  click_on 'Start group'
end
