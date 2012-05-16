require 'spec_helper'

describe Membership do
  let(:membership) { Membership.new }
  let(:user) { User.make! }
  let(:user2) { User.make! }
  let(:group) { Group.make! }

  describe "validation" do
    it "must have a group" do
      membership.valid?
      membership.should have(1).errors_on(:group)
    end

    it "must have a user" do
      membership.valid?
      membership.should have(1).errors_on(:user)
    end

    it "should have access_level of request" do
      membership.valid?
      membership.access_level.should == 'request'
    end

    it "cannot have duplicate memberships" do
      Membership.make!(:user => user, :group => group)
      membership.user = user
      membership.group = group
      membership.valid?
      membership.errors_on(:user_id).should include("has already been taken")
    end

    it "user must be a member of parent group (if one exists)" do
      group.parent = Group.make!
      group.save
      membership.group = group
      membership.user = user
      membership.valid?
      membership.errors_on(:user).should include(
        "must be a member of this group's parent")
    end
  end

  context "member can_be_deleted_by? admin" do
    it "returns true" do
      group.add_admin!(user)
      membership = group.add_member!(user2)

      membership.can_be_deleted_by?(user).should == true
    end
  end

  context "admin can_be_deleted_by? admin" do
    it "returns false" do
      # [Jon] Machinist is lame... (causing bugs which requires
      # the code below to workaround)
      group = Group.make
      group.save
      user = User.make
      user.save
      user2 = User.make
      user2.save

      group.add_admin!(user)
      membership = group.add_admin!(user2)
      group.admins.should include(user2)

      membership.can_be_deleted_by?(user).should == false
    end
  end

  context "request can_be_deleted member" do
    it "returns true" do
      group.add_member!(user)
      membership = group.add_request!(user2)

      membership.can_be_deleted_by?(user).should == true
    end
  end

  context "request can_be_deleted requester" do
    it "returns true" do
      membership = group.add_request!(user)

      membership.can_be_deleted_by?(user).should == true
    end
  end
end
