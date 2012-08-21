require 'spec_helper'

describe "Home" do
  subject { page }

  context "logged out user visits home" do
    it "sees landing page" do
      visit root_path

      should have_css('.landing')
    end
  end

  context "a logged in user" do
    before :each do
      @user = User.make!
      @group = Group.make!(name: 'Test Group', viewable_by: :members)
      @group.add_member!(@user)
      @discussion = create_discussion(group: @group)
      @motion = create_motion(name: 'Test Motion', discussion: @discussion,
                              author: @user)
      page.driver.post user_session_path, 'user[email]' => @user.email,
                                          'user[password]' => 'password'
    end

    context "visits home" do
      it "sees dashboard" do
        visit root_path

        should have_css('.dashboard')
      end
    end
  end
end
