require 'rails_helper'

describe 'GroupService' do
  let(:user) { create(:user) }
  let(:group) { build(:group) }
  let(:guest_group) { build(:guest_group) }
  let(:parent) { create(:group) }
  let(:subgroup) { build(:group, parent: parent) }

  describe 'create' do
    it 'creates a new group' do
      expect { GroupService.create(group: group, actor: user) }.to change { Group.count }.by(1)
      expect(group.reload.creator).to eq user
    end

    it 'assigns a default group cover' do
      expect(group.cover_urls[:medium]).to eq '/theme/default_group_cover.png'
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
      expect { GroupService.move(group: group, parent: parent, actor: user) }.to raise_error { CanCan::AccessDenied }
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
    let!(:source_identity) { create :group_identity, group: source }
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
      expect(target.group_identities).to    include source_identity
      expect(target.membership_requests).to include source_request

      expect(source_stance.reload.group).to eq target
      expect(source_comment.reload.group).to eq target

      expect { source.reload }.to raise_error { ActiveRecord::RecordNotFound }
    end

    it 'does not allow non-admins to merge' do
      user.update(is_admin: false)
      expect { GroupService.merge(source: source, target: target, actor: user) }.to raise_error { CanCan::AccessDenied }
    end
  end
end
