When /^I invite "(.*?)" to the group$/ do |email|
  @current_user = User.find_by_email email
  click_on "group-add-members"
  fill_in 'user_email', with: email
  click_on 'invite'
end

Then /^they should be added to the group$/ do
  Membership.where(:user_id => User.find_by_email(@current_user.email)).size.should > 0
end

Then /^I should be notified that they are already a member$/ do
  page.should have_content("#{@current_user.email} is already in the group.")
end

Then /^I should be notified that they have been invited$/ do
  page.should have_content("An invite has been sent")
end

Then /^I should be notified that the email address is invalid$/ do
  page.should have_content("The email address given seems invalid.")
end

Then /^"(.*?)" should not be a member of the group$/ do |email|
  Group.find_by_name(@group.name).users.find_by_email(email).should be_nil
end

Then /^I should see "(.*?)" listed in the invited list$/ do |email|
  find("#invited-users").should have_content(email)
end

Then /^I should not see the add member button$/ do
  find("#add-members").should_not have_content("#group-add-members")
end

Then /^I should not see the invited user list$/ do
  page.should_not have_css("#invited-users")
end

Given /^"(.*?)" has been invited to the group$/ do |email|
  User.invite_and_notify!(FactoryGirl.attributes_for(:user), FactoryGirl.create(:user), @group)
end

Given /^I am a member of a group invitable by members$/ do
  @group = FactoryGirl.create :group
  @group.members_invitable_by = :members
  @group.save!
  @group.add_member! @user
end

Given /^the group is invitable by admins$/ do
  @group.members_invitable_by = :admins
  @group.save!
end
