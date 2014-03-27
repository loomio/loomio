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

    it "cannot have duplicate memberships" do
      create(:membership, :user => user, :group => group)
      membership.user = user
      membership.group = group
      membership.valid?
      membership.errors_on(:user_id).should include("has already been taken")
    end

    it "membership_count should be less than the group max_size" do
      group.max_size = 1
      group.memberships_count = 1
      group.save
      expect { group.add_member!(user) }.to raise_error
    end
  end

  it "can have an inviter" do
    membership = user.memberships.new(:group_id => group.id)
    membership.inviter = user2
    membership.save!
    membership.inviter.should == user2
  end

  context "destroying a membership" do
    before do
      @membership = group.add_member! user
    end

    it "removes subgroup memberships if parent is hidden" do
      group.privacy = 'hidden'
      group.save
      subgroup = create(:group, parent: group, privacy: 'hidden')
      subgroup.add_member! user
      group.reload
      @membership.reload
      @membership.destroy
      subgroup.users.should_not include(user)
    end

    it "doesn't remove subgroup memberships if parent is not hidden" do
      subgroup = create(:group, parent: group)
      subgroup.add_member! user
      group.reload
      @membership.reload
      @membership.destroy
      subgroup.users.should include(user)
    end

    context do
      before do
        discussion = create_discussion group: group
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
        group2 = create(:group)
        discussion2 = create_discussion group: group2
        motion2 = create(:motion, author: user, discussion: discussion2 )
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
  end
end
