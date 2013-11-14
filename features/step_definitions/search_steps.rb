Given(/^there is a discussion in another group titled "(.*?)"$/) do |title|
	@other_group = FactoryGirl.create :group
	@other_discussion = create_discussion group: @other_group, title: title
end

Given(/^I am logged in and belong to a group$/) do
  step %{I am logged in}
  @group = FactoryGirl.create :group
  @group.add_member!(@user)
end

Given(/^there is a discussion in my group titled "(.*?)"$/) do |title|
  @discussion = create_discussion group: @group, title: title
end

Given(/^there is a discussion with description "(.*?)"$/) do |description|
  @discussion = create_discussion group: @group, description: description
end

When(/^I search for "(.*?)"$/) do |search_item|
	visit search_path(search_form: { query: search_item })
end

Then(/^I should not see the discussion with the title "(.*?)"$/) do |title|
	page.should_not have_content(@other_discussion.title)
end

Then(/^I should see a discussion with the title "(.*?)"$/) do |title|
  page.should have_content(@discussion.title)
end

Then(/^I should see the discussion with the description "(.*?)"$/) do |description|
  page.should have_content(@discussion.description)
end

Given(/^there is a motion in my group titled "(.*?)"$/) do |name|
  @discussion = create_discussion group: @group
  @motion = FactoryGirl.create :motion, discussion: @discussion, name: name
end

Then(/^I should see a motion with the title "(.*?)"$/) do |name|
  page.should have_content(@motion.name)
end

Given(/^there is a motion in another group titled "(.*?)"$/) do |name|
  @other_motion = FactoryGirl.create :motion, name: name
end

Then(/^I should not see the motion with the title "(.*?)"$/) do |name|
  page.should_not have_content(@other_motion.name)
end

Given(/^there is a motion with description "(.*?)"$/) do |description|
  @discussion = create_discussion group: @group
  @motion = FactoryGirl.create :motion, discussion: @discussion, description: description
end

Then(/^I should see the motion with the description "(.*?)"$/) do |description|
  page.should have_content(@motion.description)
end
