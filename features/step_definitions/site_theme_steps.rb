When(/^I create a theme$/) do
  visit new_theme_path
  fill_in :theme_name, with: 'Party theme'
  fill_in :theme_style, with: '.themed-element: { text-decoration: "confetti" };'
  click_on 'Create Theme'
end

Then(/^I should see my theme was created$/) do
  page.should have_content "Theme created"
  page.should have_content "Party theme"
end

When(/^I update an existing theme$/) do
  @theme = Theme.create(name: "Hotdog theme")
  visit theme_path(@theme)
  fill_in :name, with: "Corndog theme"
  click_on 'Save theme'
end

Then(/^I should see the theme was updated$/) do
  page.should have_content("Theme updated")
  page.should have_content("Corndog theme")
end

Given(/^there is a group with a theme associated$/) do
  @theme = Theme.create(name: 'blue')
  @group = FactoryGirl.create(:group, theme: @theme )
end

Then(/^I should see the theme$/) do
  page.should have_xpath("//link[contains(@href, '#{theme_assets_path(@theme)}.css')]", visible: false)
end

When(/^I visit the a discussion in that themed group$/) do
  @discussion = FactoryGirl.create :discussion, group: @group
end

When(/^I visit a login page on a subdomain of a group with a theme$/) do
  pending # express the regexp above with the code you wish you had
end
