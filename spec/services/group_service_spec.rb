require 'rails_helper'

describe 'GroupService' do

  describe 'invite' do
    let(:user) { create(:user, email: 'jim@example.com') }
    let(:group) { create(:group, name: 'parent') }
    let(:subgroup) { create(:group, name: 'subgroup', parent: group) }
    let(:subscription) { Subscription.create(max_members: nil) }

    before do
      group.subscription = subscription
      group.save!
    end

    it 'does not mark as accepted if they dont belong the group already' do
      GroupService.invite(group: group, actor: group.creator, params: {recipient_emails: [user.email]})
      expect(Membership.find_by(user_id: user.id, group_id: group.id).accepted_at).to be nil
    end

    it 'marks membership as accepted if they already belong to the parent group' do
      group.add_member!(user, inviter: group.creator)
      GroupService.invite(group: subgroup, actor: subgroup.creator, params: {recipient_emails: [user.email]})
      expect(Membership.find_by(user_id: user.id, group_id: subgroup.id).accepted_at).to_not be nil
    end

    it 'marks membership as accepted if they already belong to a subgroup' do
      subgroup.add_member!(user, inviter: subgroup.creator)
      GroupService.invite(group: group, actor: group.creator, params: {recipient_emails: [user.email]})
      expect(Membership.find_by(user_id: user.id, group_id: group.id).accepted_at).to_not be nil
    end

    it 'invites a user by email' do
      expect(group.memberships.count).to eq 1
      GroupService.invite(group: group, actor: group.creator, params: {recipient_emails: ['test@example.com']})
      expect(group.memberships.count).to eq 2
    end

    it 'restricts group to subscription.max_members (single)' do
      expect(group.memberships.count).to eq 1
      subscription.update(max_members: 1)
      expect { GroupService.invite(group: group, actor: group.creator, params: {recipient_emails: ['test@example.com']}) }.to raise_error Subscription::MaxMembersExceeded
      expect(group.memberships.count).to eq 1
    end

    it 'restricts group to subscription.max_members (multiple)' do
      expect(group.memberships.count).to eq 1
      subscription.update(max_members: 2)
      expect { GroupService.invite(group: group, actor: group.creator, params: {recipient_emails: ['test@example.com', 'test2@example.com']}) }.to raise_error Subscription::MaxMembersExceeded
      expect(group.memberships.count).to eq 1
    end
  end

  describe 'create' do
    let(:user) { create(:user) }
    let(:group) { build(:group) }

    it 'creates a new group' do
      expect { GroupService.create(group: group, actor: user) }.to change { Group.count }.by(1)
      expect(group.reload.creator).to eq user
    end
  end

  describe' move' do
    let(:group) { create :group, subscription_id: 100 }
    let(:parent) { create :group }
    let(:admin) { create :user, is_admin: true }
    let(:user) { create :user }

    it 'moves a group to a parent as an admin' do
      GroupService.move(group: group, parent: parent, actor: admin)
      expect(group.reload.parent).to eq parent
      expect(group.subscription_id).to be_nil
      expect(parent.reload.subgroups).to include group
    end

    it 'does not allow nonadmins to move groups' do
      expect { GroupService.move(group: group, parent: parent, actor: user) }.to raise_error CanCan::AccessDenied
    end
  end

  describe 'merge' do
    let!(:source) { create :group }
    let!(:target) { create :group }
    let!(:user) { create :user, is_admin: true }
    let!(:shared_user) { create :user }
    let!(:source_user) { create :user }
    let!(:target_user) { create :user }
    let!(:source_subgroup) { create :group, parent: source }
    let!(:source_discussion) { create :discussion, group: source }
    let!(:source_comment) { create :comment, discussion: source_discussion }
    let!(:source_poll) { create :poll, group: source }
    let!(:source_stance) { create :stance, poll: source_poll }
    let!(:source_request) { create :membership_request, group: source }

    before do
      source.add_member! source_user
      target.add_member! target_user
      source.add_member! shared_user
      target.add_member! shared_user
    end

    it 'can merge two groups' do
      GroupService.merge(source: source, target: target, actor: user)
      target.reload
      expect(target.subgroups).to           include source_subgroup
      expect(target.members).to             include source_user
      expect(target.members).to             include target_user
      expect(target.members).to             include shared_user
      expect(Membership.where(user: shared_user, group: target).count).to eq 1

      expect(target.discussions).to         include source_discussion
      expect(target.polls).to               include source_poll
      expect(target.membership_requests).to include source_request

      expect(source_stance.reload.group).to eq target
      expect(source_comment.reload.group).to eq target

      expect { source.reload }.to raise_error { ActiveRecord::RecordNotFound }
    end

    it 'does not allow non-admins to merge' do
      user.update(is_admin: false)
      expect { GroupService.merge(source: source, target: target, actor: user) }.to raise_error CanCan::AccessDenied
    end
  end
end
