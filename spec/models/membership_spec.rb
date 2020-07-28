require 'rails_helper'

describe Membership do
  let(:membership) { Membership.new }
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:group) { create(:group, is_visible_to_public: true) }

  describe "validation" do
    it "cannot have duplicate memberships" do
      create(:membership, :user => user, :group => group)
      membership.user = user
      membership.group = group
      membership.valid?
      membership.errors_on(:user_id).should include("has already been taken")
    end
  end

  describe 'token' do
    it 'generates a token on initialize' do
      expect(membership.token).to be_present
    end
  end

  it "can have an inviter" do
    membership = user.memberships.new(:group_id => group.id)
    membership.inviter = user2
    membership.save!
    expect(membership.inviter).to eq user2
  end

  describe 'volume' do
    before do
      @membership = create :membership, user: user, group: group, volume: :normal
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
