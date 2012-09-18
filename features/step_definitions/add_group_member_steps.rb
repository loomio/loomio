When /^I invite "(.*?)" to the group$/ do |email|
  click_on "add-members-btn"
  fill_in 'user_email', with: email
  click_on 'invite'
end

Then /^"(.*?)" should be added to the group$/ do |email|
  Membership.where(:user_id => User.find_by_email(email)).size.should > 0
end

When /^no such user is already in the group$/ do
  Membership.where(:group_id => Group.last.id, :user_id => User.last.id).size == 0
end

Given /^there is a user in the group$/ do
  visit '/groups/' + Group.last.id.to_s
  fill_in 'user_email', with: 'new_group_member@example.com'
  click_on 'invite'
end

Then /^"(.*?)" should not be a member of "(.*?)"$/ do |email, group_name|
  Group.find_by_name(group_name).users.find_by_email(email).should be_nil
end

Then /^I should be notified that "(.*?)" is already a member$/ do |email|
  page.should have_content("#{email} is already in the group.")
end

Then /^I should be notified that "(.*?)" is an invalid email$/ do |email|
  page.should have_content("#{email} was not invited. The email address given seems invalid.")
end
