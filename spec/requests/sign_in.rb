require 'spec_helper'

describe "Deactivated user logs in"do
    it %q{Given I am a Guest
      When I am in the sign_in page
      And I fill in my email
      And I fill in with my password
      And I click the Sign In button
      Then I should stay in the same page
    } do
    @user = create(:user)
    @user.deactivate!
    visit new_user_session_path
    fill_in 'user_email', :with => @user.email
    fill_in 'user_password', :with => 'wrong password'
    click_button 'Sign in'
    current_path.should == new_user_session_path # same page
  end
end