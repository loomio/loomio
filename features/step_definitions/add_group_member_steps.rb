When /^I invite "(.*?)" to the group$/ do |email|
  click_on "add-members-btn"
  fill_in 'user_email', with: email
  click_on 'invite'
end

Then /^"(.*?)" should be added to the group$/ do |email|
  Membership.where(:user_id => User.find_by_email(email)).size.should > 0
end

Given /^"(.*?)" is a member of "(.*?)"$/ do |email, group|
  Group.find_by_name(group).add_member!(User.find_by_email(email))
end

When /^no such user is already in the group$/ do
  Membership.where(:group_id => Group.last.id, :user_id => User.last.id).size == 0
end

Given /^there is a user in the group$/ do
  visit '/groups/' + Group.last.id.to_s
  fill_in 'user_email', with: 'new_group_member@example.com'
  click_on 'invite'
end

Then /^I should be notified that "(.*?)" is already a member$/ do |email|
  page.should have_content("#{email} is already in the group.")
end
