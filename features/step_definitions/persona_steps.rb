Given(/^I have authenticated with persona$/) do
  @persona = Persona.create(:email => 'bill@example.com')
  page.set_rack_session(persona_id: @persona.id)
end

When(/^I signup$/) do
  visit new_user_registration_path
  fill_in 'Full name', with: 'Bill Persona'
  fill_in 'Email', with: 'bill@example.com'
  click_on 'Sign up'
end

Given(/^I signed up to loomio manually$/) do
  @user = FactoryGirl.create(:user)
end

When(/^I log in with my exising loomio account details$/) do
  visit new_user_session_path
  fill_in 'Email', with: 'bill@example.com'
  fill_in 'Password', with: 'password'
  click_on 'Sign in'
end

Then(/^my persona should be linked to my account$/) do
  @persona = Persona.find_by_email('bill@example.com')
  @persona.user.should == User.find_by_email('bill@example.com')
  page.get_rack_session.should_not have_key :person_id
end

