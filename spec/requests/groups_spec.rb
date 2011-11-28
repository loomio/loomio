require 'spec_helper'

describe "Groups" do
  subject { page }

  context "given a logged in user" do
    before do
      @user = User.make!(email: "test123@test.com", password: "testing123")
      page.driver.post user_session_path, 'user[email]' => @user.email, 'user[password]' => 'testing123'
    end

    it "lets us view the user's groups" do
      visit '/groups'
      should have_selector('h3', text:'Your groups')
    end
  end
end
