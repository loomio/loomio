require 'rails_helper'

describe MembershipService do
  let(:group) { create :formal_group, discussion_privacy_options: :public_only, is_visible_to_public: true, membership_granted_upon: :request }
  let(:user)  { create :user }
  let(:admin) { create :user }
  let(:unverified_user) { create :user, email_verified: false }
  let(:membership) { create :membership, group: group, user: unverified_user }

  before { group.add_admin! admin }

  describe 'destroy' do
    let!(:subgroup) { create :formal_group, parent: group }
    let!(:subgroup_discussion) { create :discussion, group: subgroup, private: false }
    let!(:discussion) { create :discussion, group: group, private: false }
    let!(:poll) { create :poll, group: group }
    let!(:membership) { create :membership, user: user, group: group }

    it 'cascade deletes memberships' do
      membership
      subgroup.add_member! user
      subgroup_discussion.guest_group.add_member! user
      discussion.guest_group.add_member! user
      poll.guest_group.add_member! user
      MembershipService.destroy membership: membership, actor: user
      expect(subgroup.members).to_not include user
      expect(subgroup_discussion.members).to_not include user
      expect(discussion.members).to_not include user
      expect(poll.members).to_not include user
    end
  end

  describe 'redeem' do
    before do
      MembershipService.redeem(membership: membership, actor: user)
    end

    it 'sets accepted_at' do
      membership.accepted_at.should be_present
    end

    it 'notifies the invitor of acceptance' do
      expect(Event.last.kind).to eq 'invitation_accepted'
    end
  end
end
