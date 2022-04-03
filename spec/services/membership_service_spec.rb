require 'rails_helper'

describe MembershipService do
  let(:group) { create :group, discussion_privacy_options: :public_only, is_visible_to_public: true, membership_granted_upon: :request }
  let(:user)  { create :user }
  let(:admin) { create :user }
  let(:unverified_user) { create :user, email_verified: false }
  let(:membership) { create :membership, group: group, user: unverified_user }

  before { group.add_admin! admin }

  describe 'destroy' do
    let!(:subgroup) { create :group, parent: group }
    let!(:subgroup_discussion) { create :discussion, group: subgroup, private: false }
    let!(:discussion) { create :discussion, group: group, private: false }
    let!(:poll) { create :poll, group: group }
    let!(:membership) { create :membership, user: user, group: group }

    it 'cascade deletes memberships' do
      membership
      subgroup.add_member! user
      subgroup_discussion.add_guest! user, subgroup_discussion.author
      reader = discussion.add_guest! user, discussion.author
      stance = poll.add_guest!(user, discussion.author)
      expect(stance.inviter_id).to eq discussion.author_id
      expect(reader.inviter_id).to eq discussion.author_id
      expect(stance.revoked_at).to eq nil
      expect(reader.revoked_at).to eq nil
      MembershipService.destroy(membership: membership, actor: user)
      expect(subgroup.members).to_not include user
      expect(subgroup_discussion.members).to_not include user
      expect(discussion.members).to_not include user
      expect(poll.members).to_not include user
      expect(reader.reload.revoked_at).to_not eq nil
      expect(stance.reload.revoked_at).to_not eq nil
    end
  end

  describe 'redeem' do
    let!(:another_subgroup) { create :group, parent: group }
    let!(:discussion) { create :discussion, group: group, private: false }
    let!(:poll) { create :poll, group: group }

    it 'sets accepted_at' do
      MembershipService.redeem(membership: membership, actor: user)
      membership.accepted_at.should be_present
    end

    it 'unrevokes discussion readers and stances' do
      reader = discussion.add_guest! user, discussion.author
      stance = poll.add_guest!(user, discussion.author)
      reader.update(revoked_at: DateTime.now)
      stance.update(revoked_at: DateTime.now)
      expect(stance.revoked_at).to_not eq nil
      expect(reader.revoked_at).to_not eq nil
      MembershipService.redeem(membership: membership, actor: user)
      expect(stance.reload.revoked_at).to eq nil
      expect(reader.reload.revoked_at).to eq nil
    end

    it 'notifies the invitor of acceptance' do
      MembershipService.redeem(membership: membership, actor: user)
      expect(Event.last.kind).to eq 'invitation_accepted'
    end

  end

  describe 'with alien group' do
    let!(:alien_group) { create :group }
    let(:membership) { create :membership, group: group, inviter: admin, user: user, experiences: { invited_group_ids: [alien_group.id] }  }

    before do
      MembershipService.redeem(membership: membership, actor: user)
    end

    it 'cannot invite user to alien group' do
      expect(alien_group.members).to_not include user
    end
  end
end
