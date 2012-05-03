require 'spec_helper'

describe Group do
  context "a new group" do
    before :each do
      @group = Group.new
      @group.valid?
      @group
    end

    it "must have a name" do
      @group.should have(1).errors_on(:name)
    end
    it "has memberships" do
      @group.respond_to?(:memberships)
    end
    it "defaults to viewable by everyone" do
      @group.viewable_by.should == :everyone
    end
    it "defaults to members invitable by members" do
      @group.members_invitable_by.should == :members
    end
  end

  context "has a parent" do
    before :each do
      @group = Group.make!
      @subgroup = Group.make!(:parent => @group)
    end
    it "accesses its parent" do
      @subgroup.parent.should == @group
    end
    it "accesses its children" do
      10.times {Group.make!(:parent => @group)}
      @group.subgroups.count.should eq(11)
    end
    it "limits group inheritance to 1 level" do
      invalid = Group.make(:parent => @subgroup)
      invalid.should_not be_valid
    end
    it "can set admin of parent group as admin of subgroups" do
      @user = User.make!
      @group.add_admin!(@user)
      @subgroup.inherit_memberships!
      @subgroup.users.should include(@user)
      @subgroup.admins.should include(@user)
    end
  end

  context "an existing group viewiable by members" do
    before :each do
      @group = Group.make!(viewable_by: "members")
      @user = User.make!
    end

    it "can add an admin" do
      @group.add_admin!(@user)
      @group.users.should include(@user)
      @group.admins.should include(@user)
    end
    it "can promote existing member to admin" do
      @group.add_member!(@user)
      @group.add_admin!(@user)
    end
    it "can promote requested member to admin" do
      @group.add_request!(@user)
      @group.add_admin!(@user)
    end
    it "can add a member" do
      @group.add_member!(@user)
      @group.users.should include(@user)
    end
    it "fails silently when trying to add an already-existing member" do
      @group.add_member!(@user)
      @group.add_member!(@user)
    end
    it "fails silently when trying to request an already-requested member" do
      @group.add_request!(@user)
      @group.add_request!(@user)
    end
    it "fails silently when trying to request an already-existing member" do
      @group.add_member!(@user)
      @group.add_request!(@user)
      @group.users.should include(@user)
    end
    it "can add a member if a request has already been created" do
      @group.add_request!(@user)
      @group.add_member!(@user)
      @group.users.should include(@user)
    end

    it "can tag user" do
      # TODO Jon: technically this is a 'coupled' (bad) test, and
      # we should have separate tests for the tag_user and
      # get_user_tags methods
      @group.set_user_tags(@user, "new-tag")
      user_tags = @group.get_user_tags(@user)
      user_tags.first.name.should == "new-tag"
    end

    it "can delete user tag" do
      @group.set_user_tags(@user, "first,second")
      @group.get_user_tags(@user).first.name.should == "first"
      @group.delete_user_tag(@user, "first")
      @group.get_user_tags(@user).first.name.should == "second"


    end

    context "receiving a member request" do
      it "should not add user to group" do
        @group.add_request!(@user)
        @group.users.should_not include(@user)
      end
      it "should add user to member requests" do
        @group.add_request!(@user)
        @group.membership_requests.find_by_user_id(@user).should \
          == @user.membership_requests.find_by_group_id(@group)
      end
      it "should send group admins a notification email" do
        GroupMailer.should_receive(:new_membership_request).with(kind_of(Membership))
          .and_return(stub(deliver: true))
        @group.add_request!(@user)
      end
    end
  end

  context "checking requested users" do
    it "should return true if user has requested access to group" do
      group = Group.make!
      user = User.make!
      user2 = User.make!
      group.add_request!(user)
      group.add_request!(user2)
      group.requested_users_include?(user).should be_true
      group.requested_users_include?(user2).should be_true
    end
  end
end
