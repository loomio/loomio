When(/^I create a private discussion$/) do
  @discussion = create_discussion group: @group, author: @user, private: true
end

Then(/^I should see that the group is set to private$/) do
  visit discussion_path(@discussion)
  page.should have_css('.icon-lock')
end

When(/^I visit a public group$/) do
  @public_group = FactoryGirl.create :group, privacy: 'public'
  @public_discussion = create_discussion group: @public_group, private: false, title: "Everyone should know i hate gummy bears"
  @private_discussion = create_discussion group: @public_group, private: true, title: "No one can know I like ice cream"
  visit group_path(@public_group)
end

When(/^I visit a private group$/) do
  @private_group = FactoryGirl.create :group, privacy: 'private'
  @public_discussion = create_discussion group: @private_group, private: false, title: "Everyone should know i hate gummy bears"
  @private_discussion = create_discussion group: @private_group, private: true, title: "No one can know I like ice cream"
  visit group_path(@private_group)
end

Then(/^I should see public discussions$/) do
  page.should have_content(@public_discussion.title)
end

Then(/^I should not see private discussions$/) do
  page.should_not have_content(@private_discussion.title)
end

When(/^I change the discussion privacy to public$/) do
  visit discussion_path(@discussion)
  find('#discussion-options').click
  find('.edit-discussion').click
  find('#discussion_private_false').click
  find('#discussion-submit').click
end

Then(/^I should see that the discussion is set to public$/) do
  page.should have_css('.fa-globe')
end
