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

  describe "update_counter_cache" do
    it "decrements group.memberships_count" do
      group.should_receive(:memberships).and_return([1,2])
      group.should_receive(:memberships_count=).with(2)
      group.should_receive :save

      membership = Membership.new
      membership.group = group

      membership.send(:update_counter_cache)
    end
  end

  describe "save" do
    it "updates memberships_count" do
      membership = Membership.new
      membership.group = group
      membership.user = user
      membership.access_level = "member"

      membership.should_receive(:update_counter_cache)

      membership.save!
    end
  end

  describe "destroy" do
    it "removes subgroup memberships (if existing)" do
      membership = group.add_member! user
      # Removes user from multiple subgroups
      subgroup = Group.make
      subgroup.parent = group
      subgroup.save
      subgroup.add_member! user
      subgroup2 = Group.make
      subgroup2.parent = group
      subgroup2.save
      subgroup2.add_member! user
      # Does not try to remove user from subgroup if user is not a member
      subgroup3 = Group.make
      subgroup3.parent = group
      subgroup3.save
      membership.destroy

      subgroup.users.should_not include(user)
      subgroup2.users.should_not include(user)
    end

    it "removes open votes from user" do
      membership = group.add_member! user
      discussion = create_discussion(group: group)
      motion = create_motion(discussion: discussion)
      vote = Vote.new
      vote.user = user
      vote.position = "yes"
      vote.motion = motion
      vote.save!
      membership.destroy

      motion.votes.count.should == 0
    end

    it "updates memberships_count" do
      membership = group.add_member! user

      membership.should_receive(:update_counter_cache)

      membership.destroy
    end
  end

end
