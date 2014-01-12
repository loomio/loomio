require 'spec_helper'

describe "Groups" do
  subject { page }

  context "a logged in user" do
    before :each do
      @user = create(:user)
      @group = create(:group, name: 'Test Group', privacy: 'hidden')
      @group.add_member!(@user)
      @discussion = create_discussion group: @group, author: @user
      @motion = create(:motion, name: 'Test Motion',
                              discussion: @discussion,
                              author: @user)
      login @user
    end

    context "admin of a group" do
      before :each do
        @group.add_admin!(@user)
      end

      context "viewing a group" do
        it "can see membership request section" do
          pending "should be converted to cucs, broken as specs"
          requested_user = build(:user)
          requested_user.save
          @group.add_request!(requested_user)

          visit group_path(@group)

          should have_content("Membership requests")
        end
        it "can see add member section" do
          pending "should be converted to cucs, broken as specs"
          visit group_path(@group)

          should have_content("Add new member")
        end
      end
    end

    context "group member viewing a group" do
      it "can add a discussion" do
        pending "should be converted to cucs, broken as specs"
        visit group_path(@group)

        find('#start-new-discussion').click
        should have_css(".new_discussion")
      end
    end

    context "group member viewing a hidden group" do
      before :each do
        @group.privacy = 'hidden'
        @group.save
      end

      context "members invitable by admins only" do
        pending "should be converted to cucs, broken as specs"
        before :each do
          @group.members_invitable_by = 'admins'
          @group.save
        end

        it "cannot see membership request section" do
          pending "should be converted to cucs, broken as specs"
          requested_user = build(:user)
          requested_user.save
          @group.add_request!(requested_user)

          visit group_path(@group)

          #should_not have_content("Membership requests")
        end

        it "cannot see add member section" do
          pending "should be converted to cucs, broken as specs"
          visit group_path(@group)

          should_not have_content("Add new member")
        end
      end

      context "members invitable by members" do
        before :each do
          @group.members_invitable_by = :members
          @group.save
        end

        it "can see membership request section" do
          pending "should be converted to cucs, broken as specs"
          requested_user = build(:user)
          requested_user.save
          @group.add_request!(requested_user)

          visit group_path(@group)

          should have_content("Membership requests")
        end

        it "can see add member section" do
          pending "should be converted to cucs, broken as specs"
          visit group_path(@group)

          should have_content("Add new member")
        end

      end

      it "can view the group's contents" do
        pending "should be converted to cucs, broken as specs"
        visit group_path(@group)

        should have_content("Test Group")
        should have_content("Members")
      end
    end

    context "group non-member viewing a hidden group" do
      it "displays 'group not found' page" do
        pending "should be converted to cucs, broken as specs"
        @group2 = build(:group, name: 'Test Group2', privacy: 'hidden')
        @group2.save
        @group2.add_member!(create(:user))
        visit group_path(@group2)
        should have_content("Group not found")
        should have_no_content("Users")
      end
    end
  end

  context "logged-out user" do
    it "viewing a private group redirects to log-in" do
      pending "should be converted to cucs, broken as specs"
      @group = create(:group, name: 'Test Group', privacy: 'hidden')
      visit group_path(@group)

      should have_css("body.sessions.new")
    end
  end
end
