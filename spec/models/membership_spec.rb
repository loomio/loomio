require 'spec_helper'

describe Membership do
  let(:membership) { Membership.new }
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:group) { create(:group) }

  it { should have_many(:events).dependent(:destroy) }

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
      create(:membership, :user => user, :group => group)
      membership.user = user
      membership.group = group
      membership.valid?
      membership.errors_on(:user_id).should include("has already been taken")
    end

    it "user must be a member of parent group (if one exists)" do
      group.parent = create(:group)
      group.save
      membership.group = group
      membership.user = user
      membership.valid?
      membership.errors_on(:user).should include(
        "must be a member of this group's parent")
    end
  end

  it "can have an inviter" do
    membership = user.memberships.new(:group_id => group.id)
    membership.access_level = "member"
    membership.inviter = user2
    membership.save!
    membership.inviter.should == user2
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

  context "destroying a membership" do
    before do
      @membership = group.add_member! user
    end

    it "removes subgroup memberships (if existing)" do
      # Removes user from multiple subgroups
      subgroup = build(:group, :creator => group.creator)
      subgroup.parent = group
      subgroup.save!
      subgroup.add_member! user
      subgroup2 = build(:group, :creator => group.creator)
      subgroup2.parent = group
      subgroup2.save
      subgroup2.add_member! user
      # Does not try to remove user from subgroup if user is not a member
      subgroup3 = build(:group, :creator => group.creator)
      subgroup3.parent = group
      subgroup3.save
      @membership.destroy

      subgroup.users.should_not include(user)
      subgroup2.users.should_not include(user)
    end

    context do
      before do
        discussion = create(:discussion, group: group)
        @motion = create(:motion, discussion: discussion)
        vote = Vote.new
        vote.user = user
        vote.position = "yes"
        vote.motion = @motion
        vote.save!
      end

      it "removes user's open votes for the group" do
        @membership.destroy
        @motion.votes.count.should == 0
      end

      it "does not remove user's open votes for other groups" do
        motion2 = create(:motion, author: user)
        vote = Vote.new
        vote.user = user
        vote.position = "yes"
        vote.motion = motion2
        vote.save!
        @membership.destroy
        motion2.votes.count.should == 1
      end

      it "does not fail if motion no longer exists" do
        @motion.delete
        lambda { @membership.destroy }.should_not raise_error
      end
    end

    it "updates memberships_count" do
      @membership.should_receive(:update_counter_cache)

      @membership.destroy
    end
  end

end
