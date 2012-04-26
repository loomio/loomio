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
      should have_selector('h3', text:'Groups')
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

          should have_content("Membership requests")
        end
        it "can see add member section" do
          visit group_path(@group)

          should have_content("Add member")
        end
      end
    end

    context "group member viewing a group visible to members only" do
      before :each do
        @group.viewable_by = :members
        @group.save
      end

      context "members invitable by admins only" do
        before :each do
          @group.members_invitable_by = :admins
          @group.save
        end

        it "cannot see membership request section" do
          requested_user = User.make
          requested_user.save
          @group.add_request!(requested_user)

          visit group_path(@group)

          should_not have_content("Membership requests")
        end

        it "cannot see add member section" do
          visit group_path(@group)

          should_not have_content("Add member")
        end
      end

      context "members invitable by members" do
        before :each do
          @group.members_invitable_by = :members
          @group.save
        end

        it "can see membership request section" do
          requested_user = User.make
          requested_user.save
          @group.add_request!(requested_user)

          visit group_path(@group)

          should have_content("Membership requests")
        end

        it "can see add member section" do
          visit group_path(@group)

          should have_content("Add member")
        end

      end

      it "can view the group's contents" do
        visit group_path(@group)

        should have_content("Test Group")
        should have_content("Current members")
      end

      it "can click on 'Create a motion'" do
        visit group_path(@group)

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

  context "logged-out user" do
    it "can view a public group" do
      @user = User.make!
      @group = Group.make!(name: 'Test Group', viewable_by: :everyone)
      @group.add_member!(@user)
      @motion = create_motion(name: 'Test Motion', group: @group,
                              author: @user, facilitator: @user)
      visit group_path(@group)

      should have_content("Test Group")
    end
  end
end
