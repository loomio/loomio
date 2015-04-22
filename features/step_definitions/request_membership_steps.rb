Given(/^a visible join instanty group exists$/) do
  @group = FactoryGirl.create(:group, is_visible_to_public: true, membership_granted_upon: 'request')
end

Given(/^an approval required group exists$/) do
  @group = FactoryGirl.create(:group, is_visible_to_public: true, membership_granted_upon: 'approval')
end

Given(/^a visible but invitation only group exists$/) do
  @group = FactoryGirl.create(:group, is_visible_to_public: true, membership_granted_upon: 'invitation')
end

Then(/^I should see that membership is by invitation only$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I fill in and submit the Request membership form$/) do
  fill_in 'membership_request_name', with: @visitor_name
  fill_in 'membership_request_email', with: @visitor_email
  fill_in 'membership_request_introduction', with: "Please add me to your group, it seems like the best decission making forum ever."
  click_on "Ask to join group"
end

When(/^I fill in and submit the Request membership form \(introduction only\)$/) do
  fill_in 'membership_request_introduction', with: "Please add me to your group, it seems like the best decission making forum ever."
  click_on "Ask to join group"
end

Then(/^I should see a flash message confirming my membership request$/) do
  @group ||= @sub_group
  find('.alert-success').should have_content(I18n.t(:'success.membership_requested', which_group: @group.full_name))
end

Then(/^I should see a flash message confirming the membership request was approved$/) do
  find('.alert-success').should have_content(I18n.t(:'notice.membership_approved'))
end

Then(/^I should see a flash message confirming the membership request was ignored$/) do
  find('.alert-success').should have_content(I18n.t(:'notice.membership_request_ignored'))
end

Given(/^there is a membership request from a signed\-out user$/) do
  @membership_request = FactoryGirl.create(:membership_request,
                          group: @group, name: 'James Jones', email: 'james@jones.orf')
end

Given(/^there is a membership request from a user$/) do
  @membership_request = FactoryGirl.create(:membership_request,
                          group: @group, requestor: FactoryGirl.create(:user))
end

Given(/^I am a logged in coordinator of a group$/) do
  @group = FactoryGirl.create :group
  @user = @group.admins.first
  login @user
end

When(/^I approve the membership request$/) do
  visit group_membership_requests_path(@group)
  click_on "approve-membership-request-#{@membership_request.id}"
  # click_on "confirm-action"
end

When(/^I ignore the membership request$/) do
  visit group_membership_requests_path(@group)
  click_on "ignore-membership-request-#{@membership_request.id}"
  # click_on "confirm-action"
end

Then(/^the requester should be sent an invitation to join the group$/) do
  last_email = ActionMailer::Base.deliveries.last
  last_email.to.should include @membership_request.email
  last_email.subject.should include 'Membership approved'
end

Then(/^the requester should be added to the group$/) do
  @group.members.include?(@membership_request.requestor)
end

Then(/^I should no longer see the membership request in the list$/) do
  page.should_not have_css '#membership-request-list'
  page.should have_content I18n.t(:no_pending_membership_requests)
end

Given(/^there is an approved membership request from a user$/) do
  @group = FactoryGirl.create :group
  @membership_request = FactoryGirl.create :membership_request,
                        name: 'john testor', email: 'wine@box.flam',
                        response: 'approved', responder: @group.admins.first
end

When(/^I visit the membership requests page for the group$/) do
  visit group_membership_requests_path(@group)
end

When(/^I try to visit the membership requests page for the group$/) do
  step 'I visit the membership requests page for the group'
end

Then(/^I should not see the membership request in the list$/) do
  step 'I should no longer see the membership request in the list'
end

Then(/^I should be returned to the group page$/) do
  page.should have_css('body.groups.show')
end

Given(/^membership requests can only be managed by group admins for the group$/) do
  @group.members_can_add_members = false
  @group.save
end

Given(/^I am a member of the group$/) do
  @user ||= FactoryGirl.create :user
  @group.add_member!(@user)
end

Given(/^I have requested membership to a group$/) do
  @group = FactoryGirl.create :group
  @membership_request = FactoryGirl.create(:membership_request,
                        group: @group, requestor: @user)
end

Then(/^I should no longer see the Membership requested button$/) do
  page.should_not have_css('#membership-requested')
end

Then(/^I should see the request membership button$/) do
  page.should have_css('#request-membership')
end

Given(/^I visit the request membership page for the group$/) do
  visit new_group_membership_request_path(@group)
end

Then(/^I should see a flash message telling me I have already requested membership$/) do
  find('.alert').should have_content(I18n.t(:'error.you_have_already_requested_membership'))
end

Given(/^I have requested membership, been accepted to, and then left a group$/) do
  @group = FactoryGirl.create :group
  @membership_request = FactoryGirl.create(:membership_request,
                        group: @group, requestor: @user, responder: FactoryGirl.create(:user), response: 'approved')
end

Given(/^I have requested membership and been ignored$/) do
  @group = FactoryGirl.create :group
  FactoryGirl.create(:membership_request, group: @group, requestor: @user, responder: FactoryGirl.create(:user), response: 'ignored')
end

Given(/^I have requested membership as a visitor and been ignored$/) do
  @group = FactoryGirl.create :group
  FactoryGirl.create(:membership_request, group: @group, name: @visitor_name, email: @visitor_email, responder: FactoryGirl.create(:user), response: 'ignored')
end

Then(/^I should be redirected to the dashboard$/) do
  page.should have_css('body.dashboard.show')
end

Then(/^I should be redirected to the homepage$/) do
    page.should have_css('body.pages.home')
end

When(/^I visit the request membership page for the sub\-group$/) do
  visit new_group_membership_request_path(@sub_group)
end

Given(/^I am a visitor$/) do
  @visitor_name = "James Jones"
  @visitor_email = "james@example.orfg"
end

Given(/^I have requested membership to a group \(as a visitor\)$/) do
  @group = FactoryGirl.create :group
  @membership_request = FactoryGirl.create(:membership_request,
                        group: @group, name: @visitor_name, email: @visitor_email)
end

Then(/^I should see a field error telling me I have already requested membership$/) do
  page.should have_content(I18n.t(:'error.you_have_already_requested_membership'))
end

Then(/^I should see a flash message telling me I am already a member of the group$/) do
  find('.alert').should have_content(I18n.t(:'error.you_are_already_a_member_of_this_group'))
end


When(/^I visit the request membership page for a group$/) do
  @group = FactoryGirl.create :group
  step 'I visit the request membership page for the group'
end

When(/^I fill in and submit the Request membership form using email of existing member$/) do
  fill_in 'membership_request_name', with: @visitor_name
  fill_in 'membership_request_email', with: @group.admin_email
  fill_in 'membership_request_introduction', with: "Please add me to your group, heh heh heh."
  click_on "Ask to join group"
end

Then(/^I should see a field error telling me I am already a member of the group$/) do
  page.should have_content(I18n.t(:'error.user_with_email_address_already_in_group'))
end

Given /^I am a member of a parent\-group that has a public sub\-group$/ do
  step 'a public sub-group exists'
  @parent_group.add_member! @user
end

Then(/^the requester should be emailed of the approval$/) do
  last_email = ActionMailer::Base.deliveries.last
  last_email.to.should include @membership_request.email
  last_email.subject.should include 'Membership approved'
end

Then(/^I should be asked to log in$/) do
  page.should have_content(I18n.t(:sign_in))
end

Given(/^I am a member of a group with an invitation only subgroup that is visible to parent members$/) do
  @new_parent_group = FactoryGirl.create :group
  @new_parent_group.add_member! @user
  @subgroup = FactoryGirl.create :group,
                                  parent_id: @new_parent_group.id,
                                  is_visible_to_public: false,
                                  is_visible_to_parent_members: true,
                                  membership_granted_upon: 'invitation'
end

Then(/^I should see that I need an invitation to join$/) do
  expect(page).to have_content('Membership to this group is by invitation only')
end
