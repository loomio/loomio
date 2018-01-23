require 'rails_helper'

describe Membership do
  let(:membership) { Membership.new }
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:group) { create(:formal_group, is_visible_to_public: true) }

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
      subgroup = create(:formal_group, parent: group, is_visible_to_public: false)
      subgroup.add_member! user
      group.reload
      @membership.reload
      @membership.destroy
      subgroup.members.should_not include(user)
    end

    it "doesn't remove subgroup memberships if parent is not hidden" do
      subgroup = create(:formal_group, parent: group)
      subgroup.add_member! user
      group.reload
      @membership.reload
      @membership.destroy
      subgroup.members.should include(user)
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
