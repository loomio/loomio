require 'spec_helper'

describe "Groups" do
  subject { page }

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

    it "can view their groups" do
      visit '/groups'
      should have_selector('h1', text:'Your groups')
    end

    context "admin of a group" do
      before :each do
        @group.add_admin!(@user)
      end

      it "can visit group edit page" do
        visit edit_group_path(@group)
        current_url.should == edit_group_url(@group)
      end

      it "can edit group" do
        visit edit_group_path(@group)
        fill_in 'group_name', with: 'New groupie'
        click_on 'Update Group'
        should have_content("New groupie")
      end

      context "viewing a group" do
        it "can see membership request section" do
          requested_user = User.make
          requested_user.save
          @group.add_request!(requested_user)
          visit group_path(@group)

          should have_content("User Requests")
        end
        it "can see add member section" do
          visit group_path(@group)
          should have_content("Add member")
        end
      end
    end

    context "viewing a group visible to members only" do
      before :each do
        requested_user = User.make
        requested_user.save
        @group.add_request!(requested_user)

        visit group_path(@group)
      end

      context "members invitable by admins only" do
        it "cannot see membership request section" do
          should_not have_content("User Requests")
        end
        it "cannot see add member section"
      end

      context "members invitable by members" do
        it "can see membership request section"
        it "can see add member section"
      end

      it "can view the group's contents" do
        should have_content("Test Group")
        should have_content("Users")
      end
      it "can click on 'Create a motion'" do
        click_link 'Create a motion'
        should have_content("New motion")
      end
    end

    it "doesn't let us view a group the user does not belongs to" do
      @group2 = Group.make(name: 'Test Group2', viewable_by: :members)
      @group2.save
      @group2.add_member!(User.make!)
      visit group_path(@group2)
      should have_content("Test Group2")
      should have_no_content("Users")
    end
  end
end
