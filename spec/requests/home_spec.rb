require 'spec_helper'

describe "Home" do
  subject { page }

  context "logged out user views homepage" do
    it "sees dashboard" do
      visit root_path

      should have_css('#public-homepage')
    end
  end

  context "a logged in user" do
    before :each do
      @user = User.make!
      @group = Group.make!(name: 'Test Group', viewable_by: :members)
      @group.add_member!(@user)
      @motion = create_motion(name: 'Test Motion', group: @group,
                              author: @user, facilitator: @user)
      page.driver.post user_session_path, 'user[email]' => @user.email,
                                          'user[password]' => 'password'
    end

    context "can see dashboard" do
      it "sees dashboard" do
        visit root_path

        should have_content("Your groups")
      end
    end

    context "with motions with activity can see activity count" do
      it "sees dashboard" do
        visit root_path

        should have_css('#activity-count')
      end
    end
  end
end
