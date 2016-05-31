require 'rails_helper'

describe Membership do
  let(:membership) { Membership.new }
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:group) { create(:group, is_visible_to_public: true) }

  it { should have_many(:events).dependent(:destroy) }

  describe "validation" do
    it "cannot have duplicate memberships" do
      create(:membership, :user => user, :group => group)
      membership.user = user
      membership.group = group
      membership.valid?
      membership.errors_on(:user_id).should include("has already been taken")
    end
  end

  it "can have an inviter" do
    membership = user.memberships.new(:group_id => group.id)
    membership.inviter = user2
    membership.save!
    expect(membership.inviter).to eq user2
  end

  context "destroying a membership" do
    before do
      @membership = group.add_member! user
    end

    it "removes subgroup memberships if parent is hidden" do
      group.is_visible_to_public = false
      group.save
      subgroup = create(:group, parent: group, is_visible_to_public: false)
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
        discussion = create :discussion,  group: group
        @motion = create(:motion, discussion: discussion)
        vote = Vote.new
        vote.user = user
        vote.position = "yes"
        vote.motion = @motion
        vote.save!
      end

      it "preserves user's open votes for the group" do
        @membership.destroy
        expect(@motion.votes.count).to eq 1
      end

      it "does not remove user's open votes for other groups" do
        group2 = create(:group)
        discussion2 = create :discussion, group: group2
        motion2 = create(:motion, author: user, discussion: discussion2 )
        vote = Vote.new
        vote.user = user
        vote.position = "yes"
        vote.motion = motion2
        vote.save!
        @membership.destroy
        expect(motion2.votes.count).to eq 1
      end

      it "does not fail if motion no longer exists" do
        @motion.delete
        lambda { @membership.destroy }.should_not raise_error
      end
    end
  end

  describe 'volume' do
    before do
      @membership = create :membership, user: user, group: group, volume: :normal
    end

    it 'validates the presence of a volume' do
      @membership.volume = nil
      expect(@membership.valid?).to eq false
    end

    it 'responds to volume' do
      expect(@membership.volume.to_sym).to eq :normal
    end

    it 'can change its volume' do
      @membership.set_volume! :quiet
      expect(@membership.reload.volume.to_sym).to eq :quiet
    end
  end
end
