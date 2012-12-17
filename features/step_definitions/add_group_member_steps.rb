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
