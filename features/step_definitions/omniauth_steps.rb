Given(/^I have authenticated with omniauth/) do
  @omniauth_identity = OmniauthIdentity.create(uid: '123', provider: 'google', email: 'bill@example.com')
  page.set_rack_session(omniauth_identity_id: @omniauth_identity.id)
end

When(/^I signup$/) do
  visit new_user_registration_path
  fill_in 'user[name]', with: 'Bill Persona'
  fill_in 'user[email]', with: 'bill@example.com'
  click_on 'Create account'
end

Given(/^I signed up to loomio manually$/) do
  @user = FactoryGirl.create(:user)
end

When(/^I log in with my existing loomio account details$/) do
  visit new_user_session_path
  fill_in 'Email', with: 'bill@example.com'
  fill_in 'Password', with: 'complex_password'
  click_on 'Log in'
end

Then(/^my omniauth_identity should be linked to my account$/) do
  @omniauth_identity = OmniauthIdentity.find_by_email('bill@example.com')
  expect(@omniauth_identity.user).to eq User.find_by_email('bill@example.com')
  page.get_rack_session.should_not have_key :omniauth_identity_id
end

