require 'spec_helper'

describe "Votes" do
  subject { page }

  context "a logged in user" do
    before :each do
      @user = User.make!
      @group = Group.make!(name: 'Test Group')
      @group.add_member!(@user)
      @discussion = create_discussion(group: @group, author: @user)
      @motion = create_motion(name: 'Test Motion',
                              discussion: @discussion,
                              author: @user, facilitator: @user)
    end

    before :each do
      page.driver.post user_session_path, 'user[email]' => @user.email,
                       'user[password]' => 'password'
    end

    it "can create a vote for a motion" do
      pending
      # This test now requires javascript to execute, as clicking on the "vote-yes"
      # link does not work without it. It may be that graceful degredation of that link
      # would be good so that it works without javascript, but either way it should
      # be tested with javascript enabled.

      visit motion_path(@motion)
      click_link "Vote-yes"
      save_and_open_page
      should have_content(@motion.name)
    end
  end
end


