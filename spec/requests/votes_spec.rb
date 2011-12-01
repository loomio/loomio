require 'spec_helper'

describe "Votes" do
  subject { page }

  context "a logged in user" do
    before :each do
      @user = User.make!
      @group = Group.make!(name: 'Test Group')
      @group.add_member!(@user)
      @motion = create_motion(name: 'Test Motion', group: @group, 
                              author: @user, facilitator: @user)
    end

    before :each do
      page.driver.post user_session_path, 'user[email]' => @user.email, 
                       'user[password]' => 'password'
    end

    it "can create a vote for a motion" do
      visit motion_path(@motion)
      click_link "Cast your vote"
      select "yes", from: "Position"
      click_on "Create Vote"
      should have_content(@motion.name)
    end
  end
end


