Given(/^I am on the home page of the website$/) do
  visit '/'
end

Given(/^I am on the group selection page$/) do
  page.should have_content("body.group_sign_up.new")
end

When(/^I go to start a new group from the navbar$/) do
  find(".new-group a").click
end

When(/^I go to start a new group$/) do
  click_on "start-group-btn"
end

When(/^I fill in and submit the form$/) do
  @user = FactoryGirl.create(:user, name: "Herby Hancock", email: "herb@home.com")
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

When(/^I choose the subscription plan$/) do
  @paying_subscription = true
  find("#organisation a").click
end

When(/^I choose the pay what you can plan$/) do
  @paying_subscription = false
  find("#informal-group a").click
end

When(/^I fill in the group name and submit the form$/) do
  @group_name = "Hermans Herbs"
  fill_in :group_request_name, with: @group_name
  click_on 'sign-up-submit'
end

When(/^I sign in to Loomio$/) do
  fill_in :user_email, with:  @user.email
  fill_in :user_password, with: @user.password
  find('#sign-in-btn').click()
end

When(/^I setup the group$/) do
  fill_in :group_description, with: "A collection of the finest herbs"
  click_on 'Take me to my group!'
end

Then(/^I should see my name and email in the form$/) do
  find('#group_request_admin_name').should have_content(@user.name)
end

Then(/^I should see the thank you page$/) do
  step %{the group is created with the appropriate payment model}
  page.should have_css("body.group_requests.confirmation")
end

Then (/^the group is created with the appropriate payment model$/) do
  @group = Group.where(name: @group_name).first
  @group_request = @group.group_request
  @group.paying_subscription.should == @paying_subscription
end

Then(/^I should be added to the group as a coordinator$/) do
  @user = User.find_by_email(@group.admin_email)
  @user.adminable_groups.should include @group
end

Then (/^I should recieve an email with an invitation link$/) do
  open_email(@group_request.admin_email)
  @invitation = Invitation.find_by_recipient_email(@group_request.admin_email)
  current_email.should have_content(invitation_path(@invitation))
end

Then(/^I should see the group page with a contribute link$/) do
  page.should have_css("body.groups.show")
  page.should have_css("#contribute")
end

Then(/^I should see the group page without a contribute link$/) do
  page.should have_css("body.groups.show")
  page.should_not have_css("#contribute")
end
