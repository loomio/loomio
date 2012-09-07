require 'spec_helper'

describe "Votes" do
  subject { page }

  context "a logged in user" do
    before :each do
      @user = create(:user)
      @group = create(:group, name: 'Test Group')
      @group.add_member!(@user)
      @discussion = create(:discussion, group: @group, author: @user)
      @motion = create(:motion, name: 'Test Motion',
                              discussion: @discussion,
                              author: @user)
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


