require 'performance_test_helper'
require 'factory_girl'

class DiscussionTest < ActionDispatch::PerformanceTest
  self.profile_options = { :runs => 5,
                           :metrics => [:wall_time,
                                        :process_time,
                                        :memory],
                           :metrics => [ :process_time],
                           :formats => [:call_stack]}


  def setup
    #@user = FactoryGirl.create(:user)
    #@group = Group.find 3
    #@group.add_member! @user
    @user = User.find 1
    @group = Group.find 3
  end

  def clear_cookies
    browser = Capybara.current_session.driver.browser
    if browser.respond_to?(:clear_cookies)
      # Rack::MockSession
      browser.clear_cookies
    elsif browser.respond_to?(:manage) and browser.manage.respond_to?(:delete_all_cookies)
      # Selenium::WebDriver
      browser.manage.delete_all_cookies
    else
      raise "Don't know how to clear cookies. Weird driver?"
    end
  end

  def test_discussion_show
    clear_cookies
    visit '/users/sign_in'
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: 'password'
    click_on 'sign-in-btn'
    visit '/discussions/4440/?proposal=3550'
  end
end
